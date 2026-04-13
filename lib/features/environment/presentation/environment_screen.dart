import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/environment_controller.dart';
import '../widgets/environment_badge.dart';
import '../../../core/widgets/db_meter.dart';

class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
  static const accentGreen = Color(0xFF4CAF50);
}

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final env = context.watch<EnvironmentController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_P.bgTop, _P.bgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: _P.navy,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Environment Check',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _P.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Checking your environment…',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _P.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _P.navy,
                            ),
                          ),
                          const Spacer(),
                          EnvironmentBadge(state: env.state),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DbMeter(value: env.latestMeanDb, label: 'Live dB'),
                      const SizedBox(height: 18),
                      Text(
                        _messageFor(env.state),
                        style: TextStyle(
                          fontSize: 14,
                          color: _P.textDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (env.calibration == null)
                  _GlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: _P.navy, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Calibration is recommended for accurate noise thresholds.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _P.textDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageFor(EnvironmentState s) {
    switch (s) {
      case EnvironmentState.ok:
        return 'Environment OK. You can start practicing.';
      case EnvironmentState.noisy:
        return 'Too noisy. Please move to a quieter place for better results.';
      case EnvironmentState.unknown:
        return 'Calibration not found. Noise status is unknown.';
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _P.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _P.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}