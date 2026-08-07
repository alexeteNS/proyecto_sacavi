import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_data.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool isScanning = true;
  bool isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
        setState(() {
          isScanning = false;
        });

        final scannedContent = barcode.rawValue!.trim();
        _navigateToResultScreen(scannedContent);
        break;
      }
    }
  }

  void _navigateToResultScreen(String rawContent) async {
    final qrData = QRData(rawContent: rawContent);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(qrData: qrData),
      ),
    );

    // Al regresar de la pantalla de resultado, reactivamos el escaneo
    if (mounted) {
      setState(() {
        isScanning = true;
      });
      controller.start();
    }
  }

  void _showTestQrDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_rounded, color: Colors.indigoAccent),
                const SizedBox(width: 8),
                Text(
                  'QRs de Ejemplo (Prueba Rápida)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un tipo de QR para probar la detección y pantalla dinámica sin necesidad de cámara externa:',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.link, color: Colors.white),
              ),
              title: const Text('Enlace Web (URL)'),
              subtitle: const Text('https://flutter.dev'),
              onTap: () {
                Navigator.pop(context);
                _navigateToResultScreen('https://flutter.dev');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Icon(Icons.key, color: Colors.black87),
              ),
              title: const Text('QrScanRequest (Rust /access)'),
              subtitle: const Text('{"token": "token_acceso_secret_789", "device_id": 42}'),
              onTap: () {
                Navigator.pop(context);
                _navigateToResultScreen(
                  '{"token": "token_acceso_secret_789", "device_id": 42}',
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                child: Icon(Icons.data_object, color: Colors.white),
              ),
              title: const Text('Objeto JSON Genérico'),
              subtitle: const Text('{"usuario": "Alex", "rol": "Admin", "id": 1024}'),
              onTap: () {
                Navigator.pop(context);
                _navigateToResultScreen(
                  '{"usuario": "Alex", "rol": "Administrador", "sistema": "SACAVI", "activo": true, "permisos": ["crear", "editar", "escanear"]}',
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.wifi, color: Colors.white),
              ),
              title: const Text('Red Wi-Fi'),
              subtitle: const Text('WIFI:S:MiRedHogar;T:WPA;P:SuperClave2026;;'),
              onTap: () {
                Navigator.pop(context);
                _navigateToResultScreen('WIFI:S:MiRedHogar;T:WPA;P:SuperClave2026;;');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.badge_rounded, color: Colors.white),
              ),
              title: const Text('Tarjeta Contacto (vCard)'),
              subtitle: const Text('Juan Pérez - Ingeniero de Software'),
              onTap: () {
                Navigator.pop(context);
                _navigateToResultScreen(
                  'BEGIN:VCARD\nVERSION:3.0\nFN:Juan Pérez\nTEL:+525512345678\nEMAIL:juan.perez@empresa.com\nORG:Tech Solutions\nTITLE:Ingeniero de Software\nEND:VCARD',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanBoxSize = size.width * 0.72;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Visor de Cámara
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Oscurecimiento y Visor de Marco Cuadrado
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(140),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: scanBoxSize,
                    width: scanBoxSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Borde decorativo para el visor
          Align(
            alignment: Alignment.center,
            child: Container(
              height: scanBoxSize,
              width: scanBoxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigoAccent, width: 3),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigoAccent.withAlpha(80),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Controles Superiores (Título, Torch, Cámara)
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'QR Scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              color: isTorchOn ? Colors.amber : Colors.white,
                            ),
                            onPressed: () {
                              controller.toggleTorch();
                              setState(() {
                                isTorchOn = !isTorchOn;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                            onPressed: () => controller.switchCamera(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Indicador inferior e información
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C).withAlpha(220),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Apunta la cámara a un código QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'El escaneo navegará automáticamente a los detalles',
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _showTestQrDialog,
                        icon: const Icon(Icons.touch_app_rounded, size: 18),
                        label: const Text('Probar con QR de Ejemplo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigoAccent,
                          side: const BorderSide(color: Colors.indigoAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
