import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/utility_item.dart';
import '../providers/app_provider.dart';

class UtilityDetailPage extends StatelessWidget {
  final UtilityItem item;

  const UtilityDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: theme.copyWith(
        primaryColor: item.accentColor,
        colorScheme: theme.colorScheme.copyWith(
          primary: item.accentColor,
          secondary: item.accentColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(item.icon, color: item.accentColor),
              const SizedBox(width: 12),
              Text(
                item.nameGetter(provider.languageCode),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: item.pageBuilder(context),
          ),
        ),
      ),
    );
  }
}
