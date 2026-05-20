import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

enum _PomodoroPhase { work, shortBreak, longBreak }

class _PomodoroSettings {
  const _PomodoroSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartNext = true,
  });

  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsUntilLongBreak;
  final bool autoStartNext;

  int secondsFor(_PomodoroPhase phase) {
    return switch (phase) {
      _PomodoroPhase.work => workMinutes * 60,
      _PomodoroPhase.shortBreak => shortBreakMinutes * 60,
      _PomodoroPhase.longBreak => longBreakMinutes * 60,
    };
  }

  _PomodoroSettings copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsUntilLongBreak,
    bool? autoStartNext,
  }) {
    return _PomodoroSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsUntilLongBreak:
          sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartNext: autoStartNext ?? this.autoStartNext,
    );
  }
}

class PomodoroWidget extends StatefulWidget {
  const PomodoroWidget({super.key});

  @override
  State<PomodoroWidget> createState() => _PomodoroWidgetState();
}

class _PomodoroWidgetState extends State<PomodoroWidget> {
  static const _prefsPrefix = 'pomodoro_';

  _PomodoroSettings _settings = const _PomodoroSettings();
  bool _settingsLoaded = false;
  bool _showSettings = false;

  _PomodoroPhase _phase = _PomodoroPhase.work;
  /// Focus round in current cycle (1 .. sessionsUntilLongBreak).
  int _roundIndex = 1;
  int _completedWorkSessions = 0;
  int _remainingSeconds = 25 * 60;
  bool _running = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = _PomodoroSettings(
      workMinutes: prefs.getInt('${_prefsPrefix}work') ?? 25,
      shortBreakMinutes: prefs.getInt('${_prefsPrefix}short') ?? 5,
      longBreakMinutes: prefs.getInt('${_prefsPrefix}long') ?? 15,
      sessionsUntilLongBreak: prefs.getInt('${_prefsPrefix}rounds') ?? 4,
      autoStartNext: prefs.getBool('${_prefsPrefix}auto') ?? true,
    );
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _remainingSeconds = settings.secondsFor(_PomodoroPhase.work);
      _settingsLoaded = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefsPrefix}work', _settings.workMinutes);
    await prefs.setInt('${_prefsPrefix}short', _settings.shortBreakMinutes);
    await prefs.setInt('${_prefsPrefix}long', _settings.longBreakMinutes);
    await prefs.setInt('${_prefsPrefix}rounds', _settings.sessionsUntilLongBreak);
    await prefs.setBool('${_prefsPrefix}auto', _settings.autoStartNext);
  }

  void _applySettings({_PomodoroSettings? settings, bool resetTimer = false}) {
    final next = settings ?? _settings;
    setState(() {
      _settings = next;
      if (resetTimer && !_running) {
        _phase = _PomodoroPhase.work;
        _roundIndex = 1;
        _remainingSeconds = next.secondsFor(_PomodoroPhase.work);
      }
    });
    _saveSettings();
  }

  void _applyPreset(_PomodoroSettings preset) {
    _applySettings(settings: preset, resetTimer: true);
  }

  String _phaseLabel(AppProvider provider, _PomodoroPhase phase) {
    return switch (phase) {
      _PomodoroPhase.work => provider.translate('Fokus', 'Focus'),
      _PomodoroPhase.shortBreak => provider.translate('Istirahat', 'Break'),
      _PomodoroPhase.longBreak =>
        provider.translate('Istirahat panjang', 'Long break'),
    };
  }

  _PomodoroPhase? _nextPhaseAfter(_PomodoroPhase current) {
    if (current == _PomodoroPhase.work) {
      if (_roundIndex >= _settings.sessionsUntilLongBreak) {
        return _PomodoroPhase.longBreak;
      }
      return _PomodoroPhase.shortBreak;
    }
    return _PomodoroPhase.work;
  }

  Color _phaseColor(ThemeData theme, _PomodoroPhase phase) {
    return switch (phase) {
      _PomodoroPhase.work => theme.colorScheme.primary,
      _PomodoroPhase.shortBreak => AppTheme.tertiaryColor,
      _PomodoroPhase.longBreak => AppTheme.accentViolet,
    };
  }

  IconData _phaseIcon(_PomodoroPhase phase) {
    return switch (phase) {
      _PomodoroPhase.work => Icons.psychology_rounded,
      _PomodoroPhase.shortBreak => Icons.coffee_rounded,
      _PomodoroPhase.longBreak => Icons.weekend_rounded,
    };
  }

  void _tick() {
    if (_remainingSeconds > 0) {
      setState(() => _remainingSeconds--);
      return;
    }
    _onPhaseComplete();
  }

  void _onPhaseComplete() {
    final provider = context.read<AppProvider>();
    _timer?.cancel();

    if (_phase == _PomodoroPhase.work) {
      _completedWorkSessions++;
    }

    final completedPhase = _phase;
    final next = _nextPhaseAfter(_phase)!;

    if (completedPhase == _PomodoroPhase.shortBreak) {
      _roundIndex++;
    } else if (completedPhase == _PomodoroPhase.longBreak) {
      _roundIndex = 1;
    }

    setState(() {
      _phase = next;
      _remainingSeconds = _settings.secondsFor(next);
      _running = false;
    });

    final message = provider.translate(
      '${_phaseLabel(provider, _phase)} — ${_formatTime(_remainingSeconds)}',
      '${_phaseLabel(provider, _phase)} — ${_formatTime(_remainingSeconds)}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.translate(
            'Sesi selesai! Lanjut: $message',
            'Session done! Up next: $message',
          ),
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    if (_settings.autoStartNext) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _skipPhase() {
    _timer?.cancel();
    setState(() => _running = false);
    _onPhaseComplete();
  }

  void _resetCycle() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _phase = _PomodoroPhase.work;
      _roundIndex = 1;
      _completedWorkSessions = 0;
      _remainingSeconds = _settings.secondsFor(_PomodoroPhase.work);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_settingsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final phaseColor = _phaseColor(theme, _phase);
    final total = _settings.secondsFor(_phase);
    final progress = total > 0 ? 1 - (_remainingSeconds / total) : 0.0;
    final nextPhase = _nextPhaseAfter(_phase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phase indicator row
                Row(
                  children: [
                    _PhaseChip(
                      label: _phaseLabel(provider, _PomodoroPhase.work),
                      icon: _phaseIcon(_PomodoroPhase.work),
                      minutes: _settings.workMinutes,
                      color: _phaseColor(theme, _PomodoroPhase.work),
                      active: _phase == _PomodoroPhase.work,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _PhaseChip(
                      label: _phaseLabel(provider, _PomodoroPhase.shortBreak),
                      icon: _phaseIcon(_PomodoroPhase.shortBreak),
                      minutes: _settings.shortBreakMinutes,
                      color: _phaseColor(theme, _PomodoroPhase.shortBreak),
                      active: _phase == _PomodoroPhase.shortBreak,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _PhaseChip(
                      label: _phaseLabel(provider, _PomodoroPhase.longBreak),
                      icon: _phaseIcon(_PomodoroPhase.longBreak),
                      minutes: _settings.longBreakMinutes,
                      color: _phaseColor(theme, _PomodoroPhase.longBreak),
                      active: _phase == _PomodoroPhase.longBreak,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Session dots
                BentoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        provider.translate(
                          'Sesi fokus $_roundIndex / ${_settings.sessionsUntilLongBreak}',
                          'Focus round $_roundIndex / ${_settings.sessionsUntilLongBreak}',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(_settings.sessionsUntilLongBreak, (i) {
                        final index = i + 1;
                        final done = index < _roundIndex ||
                            (index == _roundIndex &&
                                _phase != _PomodoroPhase.work);
                        final active =
                            index == _roundIndex && _phase == _PomodoroPhase.work;
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? phaseColor
                                : AppTheme.cardAltColor(isDark),
                            border: Border.all(
                              color: active
                                  ? phaseColor
                                  : AppTheme.borderColor(isDark),
                              width: active ? 2 : 1,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Timer card
                BentoCard(
                  child: Column(
                    children: [
                      Icon(_phaseIcon(_phase), size: 28, color: phaseColor),
                      const SizedBox(height: 8),
                      Text(
                        _phaseLabel(provider, _phase),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: phaseColor,
                        ),
                      ),
                      if (nextPhase != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.translate(
                            'Berikutnya: ${_phaseLabel(provider, nextPhase)}',
                            'Up next: ${_phaseLabel(provider, nextPhase)}',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(isDark),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 10,
                                backgroundColor: AppTheme.cardAltColor(isDark),
                                color: phaseColor,
                              ),
                            ),
                            Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(isDark),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.translate(
                          'Total fokus hari ini: $_completedWorkSessions',
                          'Focus sessions today: $_completedWorkSessions',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Settings toggle
                InkWell(
                  onTap: _running
                      ? null
                      : () => setState(() => _showSettings = !_showSettings),
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: _running
                              ? AppTheme.textSecondary(isDark).withValues(alpha: 0.4)
                              : AppTheme.textSecondary(isDark),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.translate('Kustomisasi', 'Customize'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _running
                                  ? AppTheme.textSecondary(isDark).withValues(alpha: 0.4)
                                  : AppTheme.textPrimary(isDark),
                            ),
                          ),
                        ),
                        if (_running)
                          Text(
                            provider.translate('(jeda dulu)', '(pause first)'),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary(isDark),
                            ),
                          )
                        else
                          Icon(
                            _showSettings
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: AppTheme.textSecondary(isDark),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_showSettings && !_running) ...[
                  const SizedBox(height: 8),
                  _SettingsPanel(
                    settings: _settings,
                    isDark: isDark,
                    provider: provider,
                    onPreset: _applyPreset,
                    onChanged: (s) => _applySettings(settings: s, resetTimer: true),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _running ? _skipPhase : null,
              icon: const Icon(Icons.skip_next_rounded),
              tooltip: provider.translate('Lewati fase', 'Skip phase'),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetCycle,
                icon: const Icon(Icons.replay_rounded),
                label: Text(provider.translate('Reset siklus', 'Reset cycle')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _running ? _pause : _start,
                icon: Icon(
                  _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(
                  _running
                      ? provider.translate('Jeda', 'Pause')
                      : provider.translate('Mulai', 'Start'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.icon,
    required this.minutes,
    required this.color,
    required this.active,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final int minutes;
  final Color color;
  final bool active;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppTheme.cardAltColor(isDark),
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          border: Border.all(
            color: active ? color : AppTheme.borderColor(isDark),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: active ? color : AppTheme.textSecondary(isDark)),
            const SizedBox(height: 4),
            Text(
              '${minutes}m',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? color : AppTheme.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.settings,
    required this.isDark,
    required this.provider,
    required this.onPreset,
    required this.onChanged,
  });

  final _PomodoroSettings settings;
  final bool isDark;
  final AppProvider provider;
  final void Function(_PomodoroSettings) onPreset;
  final void Function(_PomodoroSettings) onChanged;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            provider.translate('Preset', 'Presets'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetChip(
                label: provider.translate('Klasik 25/5', 'Classic 25/5'),
                onTap: () => onPreset(
                  const _PomodoroSettings(
                    workMinutes: 25,
                    shortBreakMinutes: 5,
                    longBreakMinutes: 15,
                    sessionsUntilLongBreak: 4,
                  ),
                ),
                isDark: isDark,
              ),
              _PresetChip(
                label: provider.translate('Pendek 15/3', 'Short 15/3'),
                onTap: () => onPreset(
                  const _PomodoroSettings(
                    workMinutes: 15,
                    shortBreakMinutes: 3,
                    longBreakMinutes: 10,
                    sessionsUntilLongBreak: 4,
                  ),
                ),
                isDark: isDark,
              ),
              _PresetChip(
                label: provider.translate('Panjang 50/10', 'Long 50/10'),
                onTap: () => onPreset(
                  const _PomodoroSettings(
                    workMinutes: 50,
                    shortBreakMinutes: 10,
                    longBreakMinutes: 20,
                    sessionsUntilLongBreak: 3,
                  ),
                ),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DurationSlider(
            label: provider.translate('Fokus (menit)', 'Focus (min)'),
            value: settings.workMinutes,
            min: 5,
            max: 90,
            isDark: isDark,
            onChanged: (v) => onChanged(settings.copyWith(workMinutes: v)),
          ),
          _DurationSlider(
            label: provider.translate('Istirahat (menit)', 'Break (min)'),
            value: settings.shortBreakMinutes,
            min: 1,
            max: 30,
            isDark: isDark,
            onChanged: (v) => onChanged(settings.copyWith(shortBreakMinutes: v)),
          ),
          _DurationSlider(
            label: provider.translate('Istirahat panjang (menit)', 'Long break (min)'),
            value: settings.longBreakMinutes,
            min: 5,
            max: 45,
            isDark: isDark,
            onChanged: (v) => onChanged(settings.copyWith(longBreakMinutes: v)),
          ),
          _DurationSlider(
            label: provider.translate(
              'Sesi sebelum istirahat panjang',
              'Sessions before long break',
            ),
            value: settings.sessionsUntilLongBreak,
            min: 2,
            max: 8,
            isDark: isDark,
            onChanged: (v) =>
                onChanged(settings.copyWith(sessionsUntilLongBreak: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              provider.translate(
                'Otomatis mulai fase berikutnya',
                'Auto-start next phase',
              ),
              style: const TextStyle(fontSize: 14),
            ),
            value: settings.autoStartNext,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) => onChanged(settings.copyWith(autoStartNext: v)),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.cardAltColor(isDark),
      side: BorderSide(color: AppTheme.borderColor(isDark)),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary(isDark),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(isDark),
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
