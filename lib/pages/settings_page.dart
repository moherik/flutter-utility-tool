import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_currency.dart';
import '../widgets/bento_card.dart';
import '../widgets/currency_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(provider.translate('Pengaturan', 'Settings')),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppTheme.textPrimary(isDark)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                label: provider.translate('Tampilan', 'Appearance'),
                isDark: isDark,
              ),
              BentoCard(
                child: Column(
                  children: [
                    _buildRadioRow(
                      title: provider.translate(
                        'Gunakan Tema Sistem',
                        'System Default Theme',
                      ),
                      value: ThemeMode.system,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildRadioRow(
                      title: provider.translate('Tema Terang', 'Light Theme'),
                      value: ThemeMode.light,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildRadioRow(
                      title: provider.translate('Tema Gelap', 'Dark Theme'),
                      value: ThemeMode.dark,
                      groupValue: provider.themeMode,
                      onChanged: (val) => provider.changeTheme(val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                label: provider.translate('Bahasa', 'Language'),
                isDark: isDark,
              ),
              BentoCard(
                child: Column(
                  children: [
                    _buildLanguageRow(
                      title: 'Bahasa Indonesia',
                      code: 'id',
                      groupValue: provider.languageCode,
                      onChanged: (val) => provider.changeLanguage(val!),
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildLanguageRow(
                      title: 'English',
                      code: 'en',
                      groupValue: provider.languageCode,
                      onChanged: (val) => provider.changeLanguage(val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                label: provider.translate(
                  'Mata Uang Kalkulator',
                  'Calculator Currency',
                ),
                isDark: isDark,
              ),
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      provider.translate(
                        'Berlaku untuk kalkulator diskon, tip, cicilan, bunga, dan BBM.',
                        'Applies to discount, tip, loan, interest, and fuel calculators.',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const CurrencySelector(),
                    const SizedBox(height: 8),
                    Text(
                      provider.translate(
                        'Kurs konversi: 1 USD = ${AppCurrency.exchangeRate.toStringAsFixed(0)} IDR',
                        'Conversion rate: 1 USD = ${AppCurrency.exchangeRate.toStringAsFixed(0)} IDR',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                label: provider.translate(
                  'Informasi Aplikasi',
                  'About Application',
                ),
                isDark: isDark,
              ),
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
                      isDark,
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildInfoRow(
                      provider.translate('Paket', 'Package ID'),
                      'com.emas.utilityapp',
                      isDark,
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildInfoRow(
                      provider.translate('Versi', 'Version'),
                      '1.0.0',
                      isDark,
                    ),
                    Divider(height: 24, color: AppTheme.borderColor(isDark)),
                    _buildInfoRow(
                      provider.translate('Pengembang', 'Developer'),
                      'EMAS Tech Inc.',
                      isDark,
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
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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
              activeColor: AppTheme.primaryColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow({
    required String title,
    required String code,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      onTap: () => onChanged(code),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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
              activeColor: AppTheme.primaryColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(isDark),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary(isDark),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
