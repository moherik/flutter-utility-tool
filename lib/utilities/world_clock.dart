import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class WorldClockWidget extends StatefulWidget {
  const WorldClockWidget({Key? key}) : super(key: key);

  @override
  State<WorldClockWidget> createState() => _WorldClockWidgetState();
}

class _WorldClockWidgetState extends State<WorldClockWidget> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  // List of cities with timezone offsets
  final List<Map<String, dynamic>> _cities = [
    {'name': 'London', 'offset': 0, 'flag': '🇬🇧'},
    {'name': 'New York', 'offset': -5, 'flag': '🇺🇸'},
    {'name': 'Tokyo', 'offset': 9, 'flag': '🇯🇵'},
    {'name': 'Sydney', 'offset': 10, 'flag': '🇦🇺'},
    {'name': 'Jakarta', 'offset': 7, 'flag': '🇮🇩'},
    {'name': 'Paris', 'offset': 1, 'flag': '🇫🇷'},
    {'name': 'Dubai', 'offset': 4, 'flag': '🇦🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get current timezone name and UTC time
    final localTimeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final localDateStr = DateFormat('EEEE, d MMMM yyyy').format(_currentTime);
    final localOffset = _currentTime.timeZoneOffset.inHours;

    return Column(
      children: [
        // Local Time Bento
        BentoCard(
          color: theme.primaryColor.withOpacity(0.08),
          borderColor: theme.primaryColor,
          child: Column(
            children: [
              Text(
                provider.translate('Waktu Lokal Anda', 'Your Local Time'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localTimeStr,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                localDateStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "UTC ${localOffset >= 0 ? '+' : ''}$localOffset",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // World Cities list
        Text(
          provider.translate('Kota-Kota Dunia', 'World Cities'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];

              // Calculate city time using UTC + offset
              final utcTime = _currentTime.toUtc();
              final cityTime = utcTime.add(
                Duration(hours: city['offset'] as int),
              );
              final diff = (city['offset'] as int) - localOffset;

              final timeStr = DateFormat('HH:mm').format(cityTime);
              final dateStr = DateFormat('d MMM').format(cityTime);
              final diffStr = diff == 0
                  ? provider.translate('Sama dengan lokal', 'Same time')
                  : "${diff > 0 ? '+' : ''}$diff ${provider.translate('jam', 'hrs')}";

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: BentoCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        city['flag'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              diffStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
