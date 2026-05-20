import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class AgeCalculatorWidget extends StatefulWidget {
  const AgeCalculatorWidget({super.key});

  @override
  State<AgeCalculatorWidget> createState() => _AgeCalculatorWidgetState();
}

class _AgeCalculatorWidgetState extends State<AgeCalculatorWidget> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  DateTime _todayDate = DateTime.now();

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _selectTodayDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _todayDate,
      firstDate: _birthDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _todayDate) {
      setState(() {
        _todayDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate age details
    int years = _todayDate.year - _birthDate.year;
    int months = _todayDate.month - _birthDate.month;
    int days = _todayDate.day - _birthDate.day;

    if (days < 0) {
      final prevMonth = DateTime(_todayDate.year, _todayDate.month, 0);
      days += prevMonth.day;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }

    // Total detailed stats
    final totalDuration = _todayDate.difference(_birthDate);
    final totalDays = totalDuration.inDays;
    final totalWeeks = (totalDays / 7).floor();
    final totalMonths = (years * 12) + months;
    final totalHours = totalDuration.inHours;
    final totalMinutes = totalDuration.inMinutes;

    // Next birthday calculation
    DateTime nextBday = DateTime(
      _todayDate.year,
      _birthDate.month,
      _birthDate.day,
    );
    if (nextBday.isBefore(_todayDate)) {
      nextBday = DateTime(
        _todayDate.year + 1,
        _birthDate.month,
        _birthDate.day,
      );
    }
    nextBday.difference(_todayDate);
    int bdayMonths = nextBday.month - _todayDate.month;
    int bdayDays = nextBday.day - _todayDate.day;

    if (bdayDays < 0) {
      final prevMonth = DateTime(nextBday.year, nextBday.month, 0);
      bdayDays += prevMonth.day;
      bdayMonths--;
    }
    if (bdayMonths < 0) {
      bdayMonths += 12;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Pickers inside BentoCards
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  onTap: () => _selectBirthDate(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.translate('Tanggal Lahir', 'Date of Birth'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(_birthDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoCard(
                  onTap: () => _selectTodayDate(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.translate('Tanggal Hari Ini', 'Today\'s Date'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(_todayDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Age Card
          BentoCard(
            color: theme.primaryColor.withOpacity(0.08),
            borderColor: theme.primaryColor,
            child: Column(
              children: [
                Text(
                  provider.translate('Umur Anda Saat Ini', 'Your Current Age'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeBlock(
                      years,
                      provider.translate('Tahun', 'Years'),
                      theme,
                    ),
                    _buildTimeBlock(
                      months,
                      provider.translate('Bulan', 'Months'),
                      theme,
                    ),
                    _buildTimeBlock(
                      days,
                      provider.translate('Hari', 'Days'),
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Next Birthday Card
          BentoCard(
            child: Row(
              children: [
                Icon(Icons.cake_rounded, size: 36, color: theme.primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.translate(
                          'Ulang Tahun Berikutnya',
                          'Next Birthday',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bdayMonths == 0 && bdayDays == 0
                            ? provider.translate(
                                'Selamat Ulang Tahun! 🎉',
                                'Happy Birthday! 🎉',
                              )
                            : "$bdayMonths ${provider.translate('Bulan', 'Months')} $bdayDays ${provider.translate('Hari lagi', 'Days left')}",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detailed statistics
          Text(
            provider.translate(
              'Statistik Umur Detail',
              'Detailed Age Statistics',
            ),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                provider.translate('Total Bulan', 'Total Months'),
                "$totalMonths",
                isDark,
              ),
              _buildStatCard(
                provider.translate('Total Minggu', 'Total Weeks'),
                "$totalWeeks",
                isDark,
              ),
              _buildStatCard(
                provider.translate('Total Hari', 'Total Days'),
                "$totalDays",
                isDark,
              ),
              _buildStatCard(
                provider.translate('Total Jam', 'Total Hours'),
                "$totalHours",
                isDark,
              ),
              _buildStatCard(
                provider.translate('Total Menit', 'Total Minutes'),
                "$totalMinutes",
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(int val, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          "$val",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, bool isDark) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
