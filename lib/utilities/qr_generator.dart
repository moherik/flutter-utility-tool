import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class QrGeneratorWidget extends StatefulWidget {
  const QrGeneratorWidget({super.key});

  @override
  State<QrGeneratorWidget> createState() => _QrGeneratorWidgetState();
}

class _QrGeneratorWidgetState extends State<QrGeneratorWidget> {
  final TextEditingController _textController = TextEditingController(
    text: 'https://emas.com',
  );
  Color _qrColor = Colors.black;

  final List<Color> _colors = [
    AppTheme.secondaryColor,
    AppTheme.primaryColor,
    AppTheme.tertiaryColor,
    AppTheme.neutralColor,
    Colors.white,
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    final text = _textController.text;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Box Bento
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  provider.translate('Teks / URL', 'Text / URL'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _textController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: provider.translate(
                      'Masukkan teks untuk QR...',
                      'Enter text for QR code...',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // QR Code rendering
          BentoCard(
            child: Column(
              children: [
                if (text.isEmpty)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        provider.translate(
                          'Masukkan teks untuk melihat QR Code',
                          'Enter text to generate QR Code',
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.controlRadius,
                      ),
                    ),
                    child: QrImageView(
                      data: text,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                      foregroundColor: _qrColor,
                    ),
                  ),
                const SizedBox(height: 16),

                // Accent colors picker
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      final isSelected = _qrColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _qrColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Share Button
          if (text.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Share.share(text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                ),
              ),
              icon: const Icon(Icons.share_rounded),
              label: Text(provider.translate('BAGIKAN KODE', 'SHARE CODE')),
            ),
        ],
      ),
    );
  }
}
