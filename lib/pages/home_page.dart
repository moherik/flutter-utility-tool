import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/utility_item.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utility_registry.dart';
import 'settings_page.dart';
import 'utility_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groups = UtilityRegistry.getGroupedItems();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeHeader(isDark: isDark),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isLast = index == groups.length - 1;
                  return _CategorySection(
                    group: group,
                    languageCode: provider.languageCode,
                    isDark: isDark,
                    bottomPadding: isLast ? 0 : 24,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.translate('Utilitas', 'Utilities'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'UtilityTool',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppTheme.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  provider.translate(
                    'Kumpulan alat praktis dalam satu aplikasi — pilih utilitas di bawah.',
                    'A collection of practical tools in one app — pick a utility below.',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppTheme.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary(isDark),
            ),
            tooltip: provider.translate('Pengaturan', 'Settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.group,
    required this.languageCode,
    required this.isDark,
    required this.bottomPadding,
  });

  final UtilityCategoryGroup group;
  final String languageCode;
  final bool isDark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.categoryAccent(group.id);
    final label = AppTheme.categoryLabel(group.id, languageCode);
    final icon = AppTheme.categoryIcon(group.id);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryHeader(
            label: label,
            icon: icon,
            accent: accent,
            count: group.items.length,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UtilityListTile(
                item: item,
                languageCode: languageCode,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.label,
    required this.icon,
    required this.accent,
    required this.count,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(isDark),
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _UtilityListTile extends StatelessWidget {
  const _UtilityListTile({
    required this.item,
    required this.languageCode,
    required this.isDark,
  });

  final UtilityItem item;
  final String languageCode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final title = item.nameGetter(languageCode);
    final description = item.descGetter(languageCode);
    final accent = AppTheme.categoryAccent(item.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UtilityDetailPage(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Ink(
          decoration: AppTheme.surfaceDecoration(isDark),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, size: 24, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(isDark),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppTheme.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppTheme.textSecondary(isDark).withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
