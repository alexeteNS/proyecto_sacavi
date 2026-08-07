import 'dart:convert';
import 'qr_scan_request.dart';

enum QRType { url, json, vcard, wifi, email, phone, text }

class QRData {
  final String rawContent;
  final DateTime scannedAt;
  late final QRType type;

  QRData({
    required this.rawContent,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now() {
    type = _detectType(rawContent);
  }

  /// Retorna la información del QR mapeada al DTO QrScanRequest
  QrScanRequest toQrScanRequest({int? defaultDeviceId = 1}) {
    return QrScanRequest.fromRawContent(rawContent, defaultDeviceId: defaultDeviceId);
  }


  static QRType _detectType(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return QRType.url;
    }
    if (trimmed.toUpperCase().startsWith('BEGIN:VCARD')) {
      return QRType.vcard;
    }
    if (trimmed.toUpperCase().startsWith('WIFI:')) {
      return QRType.wifi;
    }
    if (trimmed.startsWith('mailto:') || RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return QRType.email;
    }
    if (trimmed.startsWith('tel:') || RegExp(r'^\+?[0-9\s\-()]{7,15}$').hasMatch(trimmed)) {
      return QRType.phone;
    }
    try {
      final decoded = json.decode(trimmed);
      if (decoded is Map || decoded is List) {
        return QRType.json;
      }
    } catch (_) {}

    return QRType.text;
  }

  // Parse JSON data if available
  dynamic get jsonParsed {
    try {
      return json.decode(rawContent.trim());
    } catch (_) {
      return null;
    }
  }

  // Parse Wi-Fi details (WIFI:S:SSID;T:WPA;P:password;;)
  Map<String, String> get wifiDetails {
    final Map<String, String> details = {
      'ssid': '',
      'password': '',
      'security': 'NOPASS',
    };
    if (type != QRType.wifi) return details;

    final clean = rawContent.trim();
    final ssidMatch = RegExp(r'S:([^;]+)').firstMatch(clean);
    final passMatch = RegExp(r'P:([^;]+)').firstMatch(clean);
    final secMatch = RegExp(r'T:([^;]+)').firstMatch(clean);

    if (ssidMatch != null) details['ssid'] = ssidMatch.group(1) ?? '';
    if (passMatch != null) details['password'] = passMatch.group(1) ?? '';
    if (secMatch != null) details['security'] = secMatch.group(1) ?? 'WPA/WPA2';

    return details;
  }

  // Parse vCard details
  Map<String, String> get vCardDetails {
    final Map<String, String> details = {
      'name': '',
      'phone': '',
      'email': '',
      'org': '',
      'title': '',
    };
    if (type != QRType.vcard) return details;

    final lines = rawContent.split(RegExp(r'\r?\n'));
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        details['name'] = line.substring(3).trim();
      } else if (line.startsWith('N:') && details['name']!.isEmpty) {
        details['name'] = line.substring(2).replaceAll(';', ' ').trim();
      } else if (line.startsWith('TEL')) {
        final parts = line.split(':');
        if (parts.length > 1) details['phone'] = parts.last.trim();
      } else if (line.startsWith('EMAIL')) {
        final parts = line.split(':');
        if (parts.length > 1) details['email'] = parts.last.trim();
      } else if (line.startsWith('ORG:')) {
        details['org'] = line.substring(4).trim();
      } else if (line.startsWith('TITLE:')) {
        details['title'] = line.substring(6).trim();
      }
    }
    return details;
  }

  Map<String, dynamic> toJson() {
    return {
      'rawContent': rawContent,
      'type': type.name,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }
}
