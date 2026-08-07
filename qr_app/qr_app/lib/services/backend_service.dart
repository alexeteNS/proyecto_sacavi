import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/qr_scan_request.dart';

/// Servicio responsable de comunicarse con el servidor backend en Rust (Axum/Serde).
class BackendService {
  /// URL base por defecto del backend (modificable dinámicamente)
  static String defaultBaseUrl = 'https://827a-201-175-210-226.ngrok-free.app';

  /// Envía la solicitud QrScanRequest a la ruta POST `/access`
  static Future<Map<String, dynamic>> sendQrToAccessEndpoint(
    QrScanRequest request, {
    String? customBaseUrl,
  }) async {
    final rawBaseUrl =
        (customBaseUrl != null && customBaseUrl.trim().isNotEmpty)
        ? customBaseUrl.trim()
        : defaultBaseUrl;

    // Asegura que la URL base no termine en / sobrante
    final cleanBaseUrl = rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;

    final uri = Uri.parse('$cleanBaseUrl/access/scan');
    final payload = request.toJson();
    final jsonBody = json.encode(payload);

    debugPrint('[BackendService] 🚀 Enviando petición POST a: $uri');
    debugPrint('[BackendService] 📦 Body JSON enviado: $jsonBody');
    debugPrint('[BackendService] 📋 cURL equivalente: curl -X POST "$uri" -H "Content-Type: application/json" -H "Accept: application/json" -d \'$jsonBody\'');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[BackendService] 📥 Código HTTP: ${response.statusCode}');
      debugPrint('[BackendService] 📥 Respuesta: ${response.body}');

      dynamic responseData;
      try {
        responseData = json.decode(response.body);
      } catch (_) {
        responseData = response.body;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': 'Acceso procesado correctamente por el servidor.',
          'data': responseData,
          'payloadSent': payload,
          'endpoint': uri.toString(),
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message':
              'Error de Solicitud (BAD_REQUEST 400): ${responseData is Map ? responseData['error'] ?? responseData['message'] ?? response.body : response.body}',
          'data': responseData,
          'payloadSent': payload,
          'endpoint': uri.toString(),
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message':
              'El servidor respondió con código HTTP ${response.statusCode}: ${response.body}',
          'data': responseData,
          'payloadSent': payload,
          'endpoint': uri.toString(),
        };
      }
    } catch (e) {
      debugPrint('[BackendService] ❌ Error de conexión: $e');
      return {
        'success': false,
        'statusCode': 0,
        'message':
            'No se pudo conectar con el servidor ($uri). Verifica que tu backend en Rust esté corriendo y que la dirección IP sea correcta.',
        'error': e.toString(),
        'payloadSent': payload,
        'endpoint': uri.toString(),
      };
    }
  }
}
