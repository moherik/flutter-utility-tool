import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class DeviceInfoWidget extends StatefulWidget {
  const DeviceInfoWidget({super.key});

  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  StreamSubscription<BatteryState>? _batterySubscription;

  Map<String, String> _deviceData = {};

  @override
  void initState() {
    super.initState();
    _loadBatteryInfo();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (!mounted) return;
      setState(() {
        _batteryLevel = level;
        _batteryState = state;
      });
      // Listen to changes
      _batterySubscription = _battery.onBatteryStateChanged.listen((
        BatteryState state,
      ) async {
        final newLevel = await _battery.batteryLevel;
        if (!mounted) return;
        setState(() {
          _batteryLevel = newLevel;
          _batteryState = state;
        });
      });
    } catch (_) {}
  }

  Future<void> _loadDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> data = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
        data = {
          'Brand': build.brand,
          'Device': build.device,
          'Model': build.model,
          'Manufacturer': build.manufacturer,
          'Android Version': build.version.release,
          'SDK Int': build.version.sdkInt.toString(),
          'Hardware': build.hardware,
          'Is Physical Device': build.isPhysicalDevice ? 'Yes' : 'No',
        };
      } else {
        data = {
          'Platform': Platform.operatingSystem,
          'Version': Platform.operatingSystemVersion,
        };
      }
    } catch (_) {
      data = {'Error': 'Could not load device info'};
    }

    if (!mounted) return;
    setState(() {
      _deviceData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Battery layout configuration
    IconData batteryIcon;
    Color batteryColor;
    switch (_batteryState) {
      case BatteryState.charging:
        batteryIcon = Icons.battery_charging_full_rounded;
        batteryColor = AppTheme.tertiaryColor;
        break;
      case BatteryState.full:
        batteryIcon = Icons.battery_full_rounded;
        batteryColor = AppTheme.tertiaryColor;
        break;
      default:
        if (_batteryLevel > 70) {
          batteryIcon = Icons.battery_6_bar_rounded;
          batteryColor = theme.primaryColor;
        } else if (_batteryLevel > 25) {
          batteryIcon = Icons.battery_4_bar_rounded;
          batteryColor = AppTheme.neutralColor;
        } else {
          batteryIcon = Icons.battery_alert_rounded;
          batteryColor = AppTheme.primaryColor;
        }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Battery Card
          BentoCard(
            color: batteryColor.withOpacity(0.08),
            borderColor: batteryColor,
            child: Row(
              children: [
                Icon(batteryIcon, size: 56, color: batteryColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.translate('STATUS BATERAI', 'BATTERY STATUS'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_batteryLevel%",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: batteryColor,
                        ),
                      ),
                      Text(
                        _batteryState == BatteryState.charging
                            ? provider.translate('Mengisi Daya', 'Charging')
                            : (_batteryState == BatteryState.full
                                  ? provider.translate('Penuh', 'Full')
                                  : provider.translate(
                                      'Tidak Mengisi Daya',
                                      'Discharging',
                                    )),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Device Information Header
          Text(
            provider.translate('Informasi Perangkat', 'Device Specifications'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Device Specifications list
          if (_deviceData.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _deviceData.length,
              itemBuilder: (context, index) {
                final key = _deviceData.keys.elementAt(index);
                final val = _deviceData[key]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: BentoCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          val,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
