import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class QuickNotesWidget extends StatefulWidget {
  const QuickNotesWidget({super.key});

  @override
  State<QuickNotesWidget> createState() => _QuickNotesWidgetState();
}

class _QuickNotesWidgetState extends State<QuickNotesWidget> {
  static const _prefsKey = 'quick_notes_content';
  final _controller = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _controller.text = prefs.getString(_prefsKey) ?? '';
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _controller.text);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().translate('Catatan disimpan', 'Note saved'),
          ),
        ),
      );
    }
  }

  Future<void> _clear() async {
    final provider = context.read<AppProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(provider.translate('Hapus catatan?', 'Clear note?')),
        content: Text(
          provider.translate(
            'Semua teks akan dihapus.',
            'All text will be removed.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(provider.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(provider.translate('Hapus', 'Clear')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _controller.clear();
    await _save();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BentoCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: provider.translate(
                  'Tulis catatan cepat di sini…',
                  'Write a quick note here…',
                ),
                border: InputBorder.none,
                filled: false,
              ),
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppTheme.textPrimary(isDark),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: Text(provider.translate('Hapus', 'Clear')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(provider.translate('Simpan', 'Save')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
