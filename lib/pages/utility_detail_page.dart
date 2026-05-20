import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/utility_item.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class UtilityDetailPage extends StatelessWidget {
  final UtilityItem item;

  const UtilityDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppTheme.categoryAccent(item.category);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.nameGetter(provider.languageCode),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppTheme.textPrimary(isDark)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: item.pageBuilder(context),
        ),
      ),
    );
  }
}
