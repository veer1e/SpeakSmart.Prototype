// Run this with: dart test_stt_diagnostic.dart
// Or: flutter pub run

import 'package:smartspeak/core/services/stt_diagnostic.dart';

void main() async {
  print('\n');
  print('╔════════════════════════════════════════╗');
  print('║   SmartSpeak STT Diagnostic Tool       ║');
  print('╚════════════════════════════════════════╝');
  print('\n');
  
  final report = await SttDiagnostic.runFullDiagnostic();
  print(report);
  
  print('\n');
  print('═════════════════════════════════════════');
  print('Diagnostic complete. Check results above.');
  print('═════════════════════════════════════════');
}
