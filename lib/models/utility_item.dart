import 'package:flutter/material.dart';

class UtilityItem {
  final String id;
  final String Function(String lang) nameGetter;
  final String Function(String lang) descGetter;
  final IconData icon;
  final String category; // 'calc', 'sensor', 'text', 'device', 'time'
  final Color accentColor;
  final int gridWidth; // 1 or 2 columns
  final int gridHeight; // 1 or 2 rows
  final Widget Function(BuildContext context) pageBuilder;
  final Widget?
  homeWidget; // Quick action widget embedded on home screen if any

  const UtilityItem({
    required this.id,
    required this.nameGetter,
    required this.descGetter,
    required this.icon,
    required this.category,
    required this.accentColor,
    required this.pageBuilder,
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.homeWidget,
  });
}
