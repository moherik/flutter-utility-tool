import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class DateCalculatorWidget extends StatefulWidget {
  const DateCalculatorWidget({super.key});

  @override
  State<DateCalculatorWidget> createState() => _DateCalculatorWidgetState();
}

class _DateCalculatorWidgetState extends State<DateCalculatorWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _dateA = DateTime.now();
  DateTime _dateB = DateTime.now().add(const Duration(days: 30));
  DateTime _baseDate = DateTime.now();
  final _daysController = TextEditingController(text: '7');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
    _daysController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  String _formatDate(DateTime d, String lang) {
    final locale = lang == 'id' ? 'id_ID' : 'en_US';
    return DateFormat.yMMMd(locale).format(d);
  }

  ({int years, int months, int days, int totalDays}) _diff(DateTime a, DateTime b) {
    final start = a.isBefore(b) ? a : b;
    final end = a.isBefore(b) ? b : a;
    final totalDays = end.difference(start).inDays;

    var years = end.year - start.year;
    var months = end.month - start.month;
    var days = end.day - start.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(end.year, end.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return (years: years, months: months, days: days, totalDays: totalDays);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = provider.languageCode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: provider.translate('Selisih', 'Difference')),
              Tab(text: provider.translate('Tambah/Kurang', 'Add/Subtract')),
            ],
          ),
          const SizedBox(height: 16),
          if (_tabController.index == 0) ...[
            BentoCard(
              child: Column(
                children: [
                  _dateRow(
                    provider.translate('Tanggal awal', 'Start date'),
                    _dateA,
                    (d) => _dateA = d,
                    lang,
                    isDark,
                  ),
                  const Divider(height: 24),
                  _dateRow(
                    provider.translate('Tanggal akhir', 'End date'),
                    _dateB,
                    (d) => _dateB = d,
                    lang,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BentoCard(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Builder(
                builder: (context) {
                  final d = _diff(_dateA, _dateB);
                  return Column(
                    children: [
                      Text(
                        provider.translate(
                          '${d.totalDays} hari total',
                          '${d.totalDays} total days',
                        ),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.translate(
                          '${d.years} tahun, ${d.months} bulan, ${d.days} hari',
                          '${d.years} years, ${d.months} months, ${d.days} days',
                        ),
                        style: TextStyle(
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else ...[
            BentoCard(
              child: Column(
                children: [
                  _dateRow(
                    provider.translate('Tanggal dasar', 'Base date'),
                    _baseDate,
                    (d) => _baseDate = d,
                    lang,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: provider.translate(
                        'Jumlah hari (+/-)',
                        'Number of days (+/-)',
                      ),
                      filled: true,
                      fillColor: AppTheme.cardAltColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final days = int.tryParse(_daysController.text) ?? 0;
                final result = _baseDate.add(Duration(days: days));
                return BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.translate('Hasil', 'Result'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(result, lang),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateRow(
    String label,
    DateTime date,
    ValueChanged<DateTime> onPicked,
    String lang,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _pickDate(date, onPicked),
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date, lang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary(isDark)),
          ],
        ),
      ),
    );
  }
}
