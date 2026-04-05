import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../calibration/controllers/calibration_controller.dart';
import '../../environment/controllers/environment_controller.dart';
import '../../environment/widgets/environment_badge.dart';


class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const navyLight = Color(0xFF2A4A62);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const labelPill = Color(0xFFE6D5F7);
  static const labelText = Color(0xFF6B3FA0);
  static const green     = Color(0xFF4CAF50);
  static const cyan      = Color(0xFF4DD0E1);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
}


class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:        _P.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: _P.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}


class _PillLabel extends StatelessWidget {
  final String text;
  const _PillLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color:      _P.textDark,
            ),
      ),
    );
  }
}


class _GlassIconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final double       size;
  const _GlassIconBtn({required this.icon, required this.onTap, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color:  Colors.white.withOpacity(0.55),
          shape:  BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
        ),
        child: Icon(icon, size: size, color: _P.textDark),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _kGap = 14;

  @override
  Widget build(BuildContext context) {
    final calib = context.watch<CalibrationController>();
    final env   = context.watch<EnvironmentController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [_P.bgTop, _P.bgBottom],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;

          Widget gap()  => const SizedBox(height: _kGap);
          Widget hgap() => const SizedBox(width: _kGap);

          
          final challengeCard = _GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color:        _P.labelPill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Today's Pronunciation Challenge",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:      _P.labelText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, Routes.practice),
                      child: Container(
                        width: 92, height: 92,
                        decoration: BoxDecoration(
                          color:  _P.navy,
                          shape:  BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:      _P.navy.withOpacity(0.35),
                              blurRadius: 16,
                              offset:     const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),

                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _ChatBubble('"I want to improve\nmy pronunciation."'),
                          SizedBox(height: 10),
                          _ChatBubble('"Lets go!"'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _P.green,
                    foregroundColor: Colors.white,
                    elevation:   4,
                    shadowColor: _P.green.withOpacity(0.4),
                    padding:     const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, Routes.practice),
                  icon:  const Icon(Icons.play_arrow_rounded, size: 26),
                  label: const Text(
                    'Start practicing',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          );

          
          final progressCard = _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PillLabel('Progress'),
                const SizedBox(height: 14),
                _ProgressBar(
                  label: 'Word Accuracy',
                  value: env.wordAccuracy,
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  label: 'Fluency',
                  value: env.fluencyScore,
                ),
              ],
            ),
          );

          
          final environmentCard = _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PillLabel('Environment'),
                const SizedBox(height: 10),
                EnvironmentBadge(state: env.state),
                const SizedBox(height: 8),
                Text(
                  'Live: ${env.latestMeanDb.toStringAsFixed(1)} dB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:      _P.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );

          
          final calibrationCard = _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PillLabel('Calibration'),
                const SizedBox(height: 6),
                Text(
                  calib.hasCalibration
                      ? 'Calibrated (updated ${calib.updatedAtLabel})'
                      : 'Not calibrated yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _P.textMuted,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _P.navy,
                        foregroundColor: Colors.white,
                        padding:       const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape:         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize:   Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:     const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => Navigator.pushNamed(context, Routes.calibration),
                      icon:  const Icon(Icons.tune, size: 13),
                      label: Text(calib.hasCalibration ? 'Recalibrate' : 'Calibrate'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _P.navy,
                        side:          const BorderSide(color: _P.navy, width: 1.2),
                        padding:       const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape:         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize:   Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:     const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => Navigator.pushNamed(context, Routes.environment),
                      icon:  const Icon(Icons.graphic_eq, size: 13),
                      label: const Text('Noise Check'),
                    ),
                  ],
                ),
              ],
            ),
          );

          
          final envCalibSection = isNarrow
              ? Column(children: [environmentCard, gap(), calibrationCard])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: environmentCard),
                    hgap(),
                    Expanded(child: calibrationCard),
                  ],
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SpeakSmart',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight:    FontWeight.w900,
                            color:         _P.textDark,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ready to practice today?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:      _P.textDark,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                
                const _WeekStrip(),
                gap(),

                
                challengeCard,
                gap(),

                
                progressCard,
                gap(),

                
                envCalibSection,
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ChatBubble extends StatelessWidget {
  final String text;
  const _ChatBubble(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(16),
          topRight:    Radius.circular(16),
          bottomLeft:  Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:      _P.textDark,
              fontFamily: 'monospace',
              height:     1.5,
            ),
      ),
    );
  }
}


class _ProgressBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 – 1.0

  const _ProgressBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:      _P.textDark,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value:           value.clamp(0.0, 1.0),
            minHeight:       9,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor:      const AlwaysStoppedAnimation<Color>(_P.cyan),
          ),
        ),
      ],
    );
  }
}


class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final today  = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final days   = List.generate(6, (i) => monday.add(Duration(days: i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final day     = days[i];
        final isToday = day.day == today.day && day.month == today.month;
        final isPast  = day.isBefore(DateTime(today.year, today.month, today.day));

        final bg = isToday
            ? _P.navy
            : isPast
                ? _P.navyLight
                : Colors.white.withOpacity(0.45);

        final fg = (isToday || isPast) ? Colors.white : _P.textDark;

        return Expanded(
          child: Column(
            children: [
              Text(
                _labels[i],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _P.textMuted, fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  boxShadow: isToday
                      ? [BoxShadow(
                          color:      _P.navy.withOpacity(0.3),
                          blurRadius: 8,
                          offset:     const Offset(0, 4),
                        )]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fg, fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}