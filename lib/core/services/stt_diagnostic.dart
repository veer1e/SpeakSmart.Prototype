/// STT Diagnostic Tool
/// 
/// Use this to test if the emulator/device can capture audio and if
/// the STT service is properly initialized.

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SttDiagnostic {
  static Future<String> runFullDiagnostic() async {
    final results = <String>[];
    
    results.add('=== STT DIAGNOSTIC REPORT ===\n');
    
    // Test 0: Check permissions
    results.add('Test 0: Check Microphone Permission');
    final micPerm = await Permission.microphone.status;
    results.add('  Permission status: ${micPerm.name}');
    if (!micPerm.isGranted) {
      results.add('  ⚠️ Permission not granted! Requesting...');
      final req = await Permission.microphone.request();
      results.add('  After request: ${req.name}');
    }
    results.add('');
    
    // Test 1: Can we initialize?
    results.add('Test 1: STT Initialization');
    final stt = SpeechToText();
    bool initialized = false;
    try {
      initialized = await stt.initialize(
        onStatus: (status) => debugPrint('[DIAG] Status: $status'),
        onError: (error) => debugPrint('[DIAG] Error: ${error.errorMsg}'),
        debugLogging: true,
      );
      results.add('  ✓ Initialization: ${initialized ? "SUCCESS" : "FAILED"}');
      if (initialized) {
        results.add('  ✓ STT is available on this device');
      }
    } catch (e) {
      results.add('  ✗ Initialization threw: $e');
      return results.join('\n');
    }
    
    if (!initialized) {
      results.add('  ✗ STT not available. Possible causes:');
      results.add('    - Emulator has no microphone configured');
      results.add('    - Google app not installed');
      results.add('    - Microphone permission denied');
      results.add('    - Audio service not responding');
      return results.join('\n');
    }
    
    results.add('  ✓ STT initialized successfully');
    results.add('');
    
    // Test 2: Try a quick listen with timeout
    results.add('Test 2: Quick Microphone Test (5 seconds)');
    results.add('  Instructions:');
    results.add('  1. Speak clearly into your PC microphone NOW');
    results.add('  2. Wait for "Listening..." to appear');
    results.add('  3. Say something like "Hello test"');
    results.add('');
    results.add('  Status: Attempting to listen...');
    
    bool gotSound = false;
    bool gotResult = false;
    String lastResult = '';
    List<double> soundLevels = [];
    
    try {
      await stt.listen(
        listenMode: ListenMode.dictation,
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        onResult: (result) {
          debugPrint('[DIAG] Result: "${result.recognizedWords}" (final: ${result.finalResult})');
          lastResult = result.recognizedWords;
          gotResult = true;
        },
        onSoundLevelChange: (level) {
          soundLevels.add(level);
          if (level > 0.01) {
            gotSound = true;
            debugPrint('[DIAG] Sound detected: level=$level');
          }
        },
      );
      
      results.add('  ✓ Listen completed');
      results.add('');
      results.add('  Results:');
      results.add('  Sound detected: ${gotSound ? "YES ✓" : "NO ✗"}');
      results.add('  Speech recognized: ${gotResult ? "YES ✓" : "NO ✗"}');
      if (gotResult) {
        results.add('  Recognized text: "$lastResult"');
      }
      results.add('  Sound levels recorded: ${soundLevels.length}');
      if (soundLevels.isNotEmpty) {
        final maxLevel = soundLevels.reduce((a, b) => a > b ? a : b);
        results.add('  Max sound level: ${(maxLevel * 100).toStringAsFixed(1)}%');
      }
      results.add('');
      
      if (!gotSound) {
        results.add('  ✗ NO SOUND DETECTED');
        results.add('  This likely means:');
        results.add('    1. Emulator microphone is NOT properly enabled');
        results.add('    2. You need to speak into your Windows PC microphone');
        results.add('    3. Check Extended Controls > Microphone setting');
        results.add('    4. Try restarting the emulator');
      }
    } catch (e) {
      results.add('  ✗ Listen threw an exception: $e');
      results.add('    This means STT service crashed');
    }
    
    await stt.stop();
    
    results.add('');
    results.add('=== RECOMMENDATIONS ===');
    if (!initialized) {
      results.add('❌ STT not available - reinstall Google app:');
      results.add('   adb install google_app.apk');
    } else if (!gotSound) {
      results.add('❌ MICROPHONE NOT WORKING:');
      results.add('   1. Open Emulator > Extended Controls');
      results.add('   2. Set Microphone to "Virtual microphone"');
      results.add('   3. Check "Allow use of host mic"');
      results.add('   4. RESTART the emulator');
      results.add('   5. Speak into your PC microphone during test');
    } else if (!gotResult) {
      results.add('⚠️  Sound detected but no speech recognized:');
      results.add('   1. Speak more clearly');
      results.add('   2. Make sure you\'re within the 5-second listening window');
      results.add('   3. Try English or check language settings');
    } else {
      results.add('✅ STT is working! Your app should now record audio.');
    }
    
    return results.join('\n');
  }
}
