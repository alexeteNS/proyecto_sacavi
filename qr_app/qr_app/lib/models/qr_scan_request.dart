import 'dart:convert';

/// Modelo de solicitud equivalente a QrScanRequest en Rust:
/// #[derive(serde::Deserialize)]
/// pub struct QrScanRequest {
///     pub token: String,
///     pub device_id: Option<i64>,
/// }
class QrScanRequest {
  final String token;
  final int? deviceId;

  QrScanRequest({
    required this.token,
    this.deviceId,
  });

  /// Crea un objeto QrScanRequest a partir del contenido crudo escaneado.
  /// 
  /// Si el QR contiene un JSON como `{"token": "xyz123", "device_id": 42}`,
  /// extrae ambos valores. Si es solo texto plano o un token directo, asigna
  /// todo el contenido como `token` y `deviceId` como null.
  factory QrScanRequest.fromRawContent(
    String rawContent, {
    int? defaultDeviceId = 1,
  }) {
    final clean = rawContent.trim();
    try {
      final decoded = json.decode(clean);
      if (decoded is Map<String, dynamic>) {
        final extractedToken = decoded['token']?.toString() ?? clean;
        int? extractedDeviceId;

        if (decoded['device_id'] != null) {
          extractedDeviceId = int.tryParse(decoded['device_id'].toString());
        } else if (decoded['deviceId'] != null) {
          extractedDeviceId = int.tryParse(decoded['deviceId'].toString());
        }

        return QrScanRequest(
          token: extractedToken,
          deviceId: extractedDeviceId ?? defaultDeviceId,
        );
      }
    } catch (_) {}

    return QrScanRequest(
      token: clean,
      deviceId: defaultDeviceId,
    );
  }

  /// Retorna la representación JSON con la clave `device_id` esperada por Rust.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'device_id': deviceId,
    };
  }
}
