import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../calibration/controllers/calibration_controller.dart';
import '../../environment/controllers/environment_controller.dart';
import '../../environment/widgets/environment_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _kGap = 12;

  @override
  Widget build(BuildContext context) {
    final calib = context.watch<CalibrationController>();
    final env = context.watch<EnvironmentController>();
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        
        final isNarrow = constraints.maxWidth < 520;

        Widget gap() => const SizedBox(height: _kGap);
        Widget hgap() => const SizedBox(width: _kGap);

        
        final challengeCard = Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pushNamed(context, Routes.practice),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Today's Pronunciation Challenge",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: 92,
                      height: 92,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => Navigator.pushNamed(context, Routes.practice),
                        child: const Icon(Icons.mic, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '“I want to improve my pronunciation.”',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the mic to start practicing',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );

        // ----- Environment Card -----
        final environmentCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Environment', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                EnvironmentBadge(state: env.state),
                const SizedBox(height: 10),
                Text('Live: ${env.latestMeanDb.toStringAsFixed(1)} dB'),
              ],
            ),
          ),
        );

        // ----- Calibration Card -----
        final calibrationCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calibration', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  calib.hasCalibration
                      ? 'Calibrated (updated ${calib.updatedAtLabel})'
                      : 'Not calibrated yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                // Wrap keeps buttons nice on narrow phones (no overflow).
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, Routes.calibration),
                      icon: const Icon(Icons.tune),
                      label: Text(calib.hasCalibration ? 'Recalibrate' : 'Calibrate'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, Routes.environment),
                      icon: const Icon(Icons.graphic_eq),
                      label: const Text('Noise Check'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        // ----- Mini Calendar -----
        final calendarCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _MiniCalendar(
              month: DateTime.now(),
              highlightDays: const {}, // keep simple for now
            ),
          ),
        );

        // ----- Daily Progress -----
        final progressCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Progress', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.local_fire_department, size: 42, color: scheme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '${env.streakDays}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'streak day(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Practices today: ${env.practicesToday}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );

        // ----- Responsive sections -----
        final envCalibSection = isNarrow
            ? Column(
                children: [
                  environmentCard,
                  gap(),
                  calibrationCard,
                ],
              )
            : Row(
                children: [
                  Expanded(child: environmentCard),
                  hgap(),
                  Expanded(child: calibrationCard),
                ],
              );

        final calendarProgressSection = isNarrow
            ? Column(
                children: [
                  calendarCard,
                  gap(),
                  progressCard,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: calendarCard),
                  hgap(),
                  Expanded(child: progressCard),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('SpeakSmart', style: Theme.of(context).textTheme.headlineSmall),
              gap(),

              // Big mic card
              challengeCard,
              gap(),

              // Environment + Calibration
              envCalibSection,
              gap(),

              // Calendar + Daily Progress
              calendarProgressSection,
            ],
          ),
        );
      },
    );
  }
}

/// Simple “mini calendar” without external packages.
/// (Shows current month grid + highlights today.)
class _MiniCalendar extends StatelessWidget {
  final DateTime month;
  final Set<int> highlightDays; // day numbers to highlight (optional)

  const _MiniCalendar({
    required this.month,
    required this.highlightDays,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weekdayOffset = (first.weekday % 7); // Sun=0, Mon=1 ... Sat=6
    final today = DateTime.now();
    final isSameMonth = (today.year == month.year && today.month == month.month);

    const labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (month + year)
        Row(
          children: [
            Text(
              _monthName(month.month),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '${month.year}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            const Icon(Icons.calendar_month, size: 18),
          ],
        ),
        const SizedBox(height: 10),

        // Weekday row
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.15,
          children: [
            for (int i = 0; i < weekdayOffset; i++) const SizedBox.shrink(),
            for (int d = 1; d <= daysInMonth; d++)
              _DayCell(
                day: d,
                isToday: isSameMonth && d == today.day,
                isHighlighted: highlightDays.contains(d),
              ),
          ],
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isHighlighted;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bg = isToday
        ? scheme.primary
        : isHighlighted
            ? scheme.primary.withOpacity(0.12)
            : scheme.surface;

    final fg = isToday ? scheme.onPrimary : scheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            ),
      ),
    );
  }
}