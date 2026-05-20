import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({super.key});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  String _scanResult = '';
  bool _cameraActive = true;
  final TextEditingController _fallbackController = TextEditingController();

  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _scanResult = code;
          _cameraActive = false; // Turn camera off after successful scan
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Scan Window Card
          BentoCard(
            padding: EdgeInsets.zero,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                child: _cameraActive
                    ? MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      )
                    : Container(
                        color: AppTheme.cardAltColor(isDark),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 64,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.translate(
                                  'Pemindaian Selesai / Dijeda',
                                  'Scan Complete / Paused',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _scanResult = '';
                                    _cameraActive = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.controlRadius,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(
                                  provider.translate(
                                    'PINDAI LAGI',
                                    'SCAN AGAIN',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fallback manual input for emulator/web
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  provider.translate(
                    'Simulator / Input Manual (Fallback)',
                    'Simulator / Manual Input (Fallback)',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fallbackController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: provider.translate(
                            'Ketik teks tiruan QR...',
                            'Type mock QR text...',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded),
                      color: theme.primaryColor,
                      onPressed: () {
                        if (_fallbackController.text.isNotEmpty) {
                          setState(() {
                            _scanResult = _fallbackController.text;
                            _cameraActive = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scan Result Details Card
          if (_scanResult.isNotEmpty)
            BentoCard(
              color: theme.primaryColor.withOpacity(0.08),
              borderColor: theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    provider.translate('HASIL PINDAI', 'SCAN RESULT'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _scanResult,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _scanResult));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.translate(
                                  'Hasil disalin!',
                                  'Result copied!',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {
                          Share.share(_scanResult);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
