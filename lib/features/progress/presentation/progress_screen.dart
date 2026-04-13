import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../environment/controllers/environment_controller.dart';

class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _P.navy,
                  ),
                ),
                const SizedBox(height: 20),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This device',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Streak',
                        value: '${env.streakDays} day(s)',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.repeat,
                        label: 'Total practices',
                        value: '${env.totalPractices}',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.bar_chart,
                        label: 'Average score',
                        value: '${env.averageScore.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: _P.navy,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Practice short phrases daily to improve consistency.',
                          style: TextStyle(
                            fontSize: 14,
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

  static Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _P.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: _P.textDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _P.navy,
          ),
        ),
      ],
    );
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