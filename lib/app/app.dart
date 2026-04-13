import 'package:flutter/material.dart';

import '../features/login/loading_screen.dart';
import '../features/login/login_screen.dart';
import 'routes.dart';
import 'theme.dart';

class SmartSpeakApp extends StatelessWidget {
  const SmartSpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakSmart',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: LoadingScreen(
        nextPageBuilder: (_) => const LoginScreen(),
        delay: const Duration(seconds: 2),
      ),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
