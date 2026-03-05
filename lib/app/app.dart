import 'package:flutter/material.dart';

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
      initialRoute: Routes.shell,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
