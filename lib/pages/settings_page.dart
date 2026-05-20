import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.translate('Pengaturan', 'Settings'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme settings bento
              Text(
                provider.translate('TAMPILAN', 'APPEARANCE'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              BentoCard(
                child: Column(
                  children: [
                    _buildRadioRow(
                      context: context,
                      title: provider.translate(
                        'Gunakan Tema Sistem',
                        'System Default Theme',
                      ),
                      value: ThemeMode.system,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                      theme: theme,
                    ),
                    const Divider(height: 20),
                    _buildRadioRow(
                      context: context,
                      title: provider.translate('Tema Terang', 'Light Theme'),
                      value: ThemeMode.light,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                      theme: theme,
                    ),
                    const Divider(height: 20),
                    _buildRadioRow(
                      context: context,
                      title: provider.translate('Tema Gelap', 'Dark Theme'),
                      value: ThemeMode.dark,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Language settings bento
              Text(
                provider.translate('BAHASA', 'LANGUAGE'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              BentoCard(
                child: Column(
                  children: [
                    _buildLanguageRow(
                      context: context,
                      title: 'Bahasa Indonesia',
                      code: 'id',
                      groupValue: provider.languageCode,
                      onChanged: (val) => provider.changeLanguage(val!),
                      theme: theme,
                    ),
                    const Divider(height: 20),
                    _buildLanguageRow(
                      context: context,
                      title: 'English',
                      code: 'en',
                      groupValue: provider.languageCode,
                      onChanged: (val) => provider.changeLanguage(val!),
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App information
              Text(
                provider.translate('INFORMASI APLIKASI', 'ABOUT APPLICATION'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoRow(
                      provider.translate('Nama Aplikasi', 'App Name'),
                      provider.translate(
                        'Utilitas All-In-One',
                        'All-In-One Utilities',
                      ),
                      theme,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      provider.translate('Paket', 'Package ID'),
                      'com.emas.utilityapp',
                      theme,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      provider.translate('Versi', 'Version'),
                      '1.0.0',
                      theme,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      provider.translate('Pengembang', 'Developer'),
                      'EMAS Tech Inc.',
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioRow({
    required BuildContext context,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Radio<ThemeMode>(
            value: value,
            groupValue: groupValue,
            activeColor: theme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow({
    required BuildContext context,
    required String title,
    required String code,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onChanged(code),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Radio<String>(
            value: code,
            groupValue: groupValue,
            activeColor: theme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
