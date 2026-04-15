import 'package:flutter/material.dart';

import '../features/shell/presentation/shell_screen.dart';
import '../features/calibration/presentation/calibration_screen.dart';
import '../features/practice/presentation/practice_screen.dart';
import '../features/feedback/presentation/feedback_screen.dart';
import '../features/environment/presentation/environment_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/practice/models/score_result.dart';
import '../features/settings/presentation/tts_settings_screen.dart';


class Routes {
  static const shell = '/';
  static const calibration = '/calibration';
  static const practice = '/practice';
  static const environment = '/environment';
  static const progress = '/progress';
  static const profile = '/profile';
  static const feedback = '/feedback';
  static const ttsSettings = '/settings/tts';
  static const sttDebug = '/debug/stt';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute(builder: (_) => const ShellScreen());
      case calibration:
        return MaterialPageRoute(builder: (_) => const CalibrationScreen());
      case practice:
        return MaterialPageRoute(builder: (_) => const PracticeScreen());
      case environment:
        return MaterialPageRoute(builder: (_) => const EnvironmentScreen());
      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case feedback:
        final result = settings.arguments as ScoreResult;
        return MaterialPageRoute(builder: (_) => FeedbackScreen(result: result));
      case ttsSettings:
        return MaterialPageRoute(builder: (_) => const TtsSettingsScreen());
      case sttDebug:
        final result = settings.arguments as ScoreResult;
        return MaterialPageRoute(builder: (_) => FeedbackScreen(result: result));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
        );
    }
  }
}
