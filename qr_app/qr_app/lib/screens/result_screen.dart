import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/qr_data.dart';
import '../services/backend_service.dart';


class ResultScreen extends StatefulWidget {
  final QRData qrData;

  const ResultScreen({super.key, required this.qrData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSendingToBackend = false;
  bool _showWifiPassword = false;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: BackendService.defaultBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Expanded(child: Text('$label copiado al portapapeles')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir la URL: $urlString'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleBackendSubmit() async {
    setState(() {
      _isSendingToBackend = true;
    });

    final qrRequest = widget.qrData.toQrScanRequest();
    final response = await BackendService.sendQrToAccessEndpoint(
      qrRequest,
      customBaseUrl: _urlController.text,
    );

    setState(() {
      _isSendingToBackend = false;
    });

    if (mounted) {
      final isSuccess = response['success'] == true;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isSuccess ? 'Acceso Exitoso' : 'Error en /access',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  response['message'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 14),
                const Text('Endpoint:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                SelectableText(
                  response['endpoint'].toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.indigoAccent),
                ),
                const SizedBox(height: 12),
                const Text('Payload enviado (QrScanRequest):', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    json.encode(response['payloadSent']),
                    style: const TextStyle(fontFamily: 'monospace', color: Colors.tealAccent, fontSize: 12),
                  ),
                ),
                if (response['data'] != null) ...[
                  const SizedBox(height: 12),
                  const Text('Respuesta Servidor Rust:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      response['data'] is String ? response['data'] : json.encode(response['data']),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isSuccess ? Colors.lightGreenAccent : Colors.orangeAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del QR Escaneado'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copiar todo',
            onPressed: () => _copyToClipboard(widget.qrData.rawContent, 'Contenido del QR'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge del Tipo de QR
            _buildTypeBadge(),

            const SizedBox(height: 20),

            // Tarjeta de Contenido Dinámico según tipo
            _buildDynamicContentCard(),

            const SizedBox(height: 24),

            // Vista de Texto/Payload Completo
            const Text(
              'Texto Completo en Crudo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withAlpha(40)),
              ),
              child: SelectableText(
                widget.qrData.rawContent,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),

            const SizedBox(height: 32),

            // Botones de Acción
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(widget.qrData.rawContent, 'Texto'),
                icon: const Icon(Icons.content_copy_rounded),
                label: const Text('Copiar al Portapapeles'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Seccion Backend Rust /access
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigoAccent.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_rounded, color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Payload QrScanRequest (Rust)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final req = widget.qrData.toQrScanRequest();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                              children: [
                                const TextSpan(text: 'Token: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                                TextSpan(text: req.token),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                              children: [
                                const TextSpan(text: 'Device ID: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                                TextSpan(text: req.deviceId != null ? req.deviceId.toString() : 'null (None)'),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'URL Servidor Backend (Rust)',
                      hintText: 'https://d8d9-201-143-7-92.ngrok-free.app',

                      isDense: true,
                      prefixIcon: const Icon(Icons.dns_rounded, size: 18, color: Colors.indigoAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSendingToBackend ? null : _handleBackendSubmit,
                      icon: _isSendingToBackend
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSendingToBackend ? 'Validando Acceso...' : 'Enviar a Rust POST /access',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botón Escanear Otro
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Escanear Otro Código'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    IconData icon;
    String label;
    Color color;

    switch (widget.qrData.type) {
      case QRType.url:
        icon = Icons.language_rounded;
        label = 'Enlace Web (URL)';
        color = Colors.blueAccent;
        break;
      case QRType.json:
        icon = Icons.data_object_rounded;
        label = 'Objeto JSON';
        color = Colors.purpleAccent;
        break;
      case QRType.vcard:
        icon = Icons.badge_rounded;
        label = 'Tarjeta de Contacto (vCard)';
        color = Colors.teal;
        break;
      case QRType.wifi:
        icon = Icons.wifi_rounded;
        label = 'Red Wi-Fi';
        color = Colors.amber;
        break;
      case QRType.email:
        icon = Icons.email_rounded;
        label = 'Correo Electrónico';
        color = Colors.orangeAccent;
        break;
      case QRType.phone:
        icon = Icons.phone_rounded;
        label = 'Número Telefónico';
        color = Colors.greenAccent;
        break;
      case QRType.text:
        icon = Icons.text_snippet_rounded;
        label = 'Texto Plano';
        color = Colors.indigoAccent;
        break;
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContentCard() {
    switch (widget.qrData.type) {
      case QRType.url:
        return _buildUrlView();
      case QRType.json:
        return _buildJsonView();
      case QRType.vcard:
        return _buildVCardView();
      case QRType.wifi:
        return _buildWifiView();
      case QRType.email:
        return _buildEmailView();
      case QRType.phone:
        return _buildPhoneView();
      case QRType.text:
        return _buildTextView();
    }
  }


  Widget _buildUrlView() {
    final url = widget.qrData.rawContent;
    return Card(
      elevation: 0,
      color: Colors.blueAccent.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blueAccent.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.public, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text(
                  'Enlace Detectado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openUrl(url),
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Abrir en el Navegador'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonView() {
    final parsed = widget.qrData.jsonParsed;
    return Card(
      elevation: 0,
      color: Colors.purple.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.purpleAccent.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.data_object_rounded, color: Colors.purpleAccent),
                SizedBox(width: 10),
                Text(
                  'Estructura JSON',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (parsed is Map) ...[
              ...parsed.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            entry.value.toString(),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  )),
            ] else ...[
              SelectableText(
                parsed.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildVCardView() {
    final vcard = widget.qrData.vCardDetails;
    return Card(
      elevation: 0,
      color: Colors.teal.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.teal.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 24,
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vcard['name']!.isNotEmpty ? vcard['name']! : 'Contacto Sin Nombre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vcard['title']!.isNotEmpty)
                        Text(
                          vcard['title']!,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      if (vcard['org']!.isNotEmpty)
                        Text(
                          vcard['org']!,
                          style: const TextStyle(color: Colors.tealAccent, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (vcard['phone']!.isNotEmpty) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_rounded, color: Colors.tealAccent),
                title: Text(vcard['phone']!),
                trailing: IconButton(
                  icon: const Icon(Icons.call_rounded, color: Colors.greenAccent),
                  onPressed: () => _openUrl('tel:${vcard['phone']}'),
                ),
              ),
            ],
            if (vcard['email']!.isNotEmpty) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_rounded, color: Colors.tealAccent),
                title: Text(vcard['email']!),
                trailing: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.orangeAccent),
                  onPressed: () => _openUrl('mailto:${vcard['email']}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWifiView() {
    final wifi = widget.qrData.wifiDetails;
    return Card(
      elevation: 0,
      color: Colors.amber.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.amber.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wifi_rounded, color: Colors.amber, size: 28),
                SizedBox(width: 10),
                Text(
                  'Credenciales Wi-Fi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Nombre de Red (SSID): ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText(
                    wifi['ssid']!,
                    style: const TextStyle(fontSize: 16, color: Colors.amberAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Seguridad: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(wifi['security']!),
              ],
            ),
            const SizedBox(height: 12),
            if (wifi['password']!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showWifiPassword ? wifi['password']! : '••••••••••••',
                        style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_showWifiPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showWifiPassword = !_showWifiPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.amberAccent),
                      onPressed: () => _copyToClipboard(wifi['password']!, 'Contraseña Wi-Fi'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailView() {
    final email = widget.qrData.rawContent.replaceAll('mailto:', '');
    return Card(
      elevation: 0,
      color: Colors.orangeAccent.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.orangeAccent.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.email_rounded, color: Colors.orangeAccent),
                SizedBox(width: 10),
                Text(
                  'Correo Electrónico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              email,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openUrl('mailto:$email'),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Redactar Correo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneView() {
    final phone = widget.qrData.rawContent.replaceAll('tel:', '');
    return Card(
      elevation: 0,
      color: Colors.greenAccent.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.greenAccent.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_rounded, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text(
                  'Teléfono',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              phone,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openUrl('tel:$phone'),
                icon: const Icon(Icons.call_rounded),
                label: const Text('Llamar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextView() {
    final text = widget.qrData.rawContent;
    return Card(
      elevation: 0,
      color: Colors.indigoAccent.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.indigoAccent.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields_rounded, color: Colors.indigoAccent),
                const SizedBox(width: 10),
                const Text(
                  'Texto Plano',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigoAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  '${text.length} caracteres',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
