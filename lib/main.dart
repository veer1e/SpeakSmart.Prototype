import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/calibration/controllers/calibration_controller.dart';
import 'features/environment/controllers/environment_controller.dart';
import 'features/practice/controllers/practice_controller.dart';
import 'core/services/storage_service.dart';
import 'core/services/stt_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/audio_level_service.dart';
import 'features/login/auth_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final tts = TtsService(storage: storage);
  await tts.init();

  final stt = SttService();
  await stt.init();

  final audio = AudioLevelService();
  await audio.init();

  final auth = AuthService();
     await auth.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: tts),
        Provider.value(value: stt),
        Provider.value(value: audio),
        Provider.value(value: auth),

        ChangeNotifierProvider(
          create: (_) => CalibrationController(storage: storage, audio: audio)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => EnvironmentController(storage: storage, audio: audio)..start(),
        ),
        ChangeNotifierProvider(
          create: (_) => PracticeController(storage: storage, stt: stt, tts: tts),
        ),
      ],
      child: const SmartSpeakApp(),
    ),
  );
}
