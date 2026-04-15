# STT Emulator Setup & Troubleshooting Guide

## Quick Diagnosis

Before diving into fixes, run the **STT Diagnostic Tool**:

```dart
import 'package:smartspeak/core/services/stt_diagnostic.dart';

// In your app or debug console:
final report = await SttDiagnostic.runFullDiagnostic();
print(report);
```

---

## Issue: "No Input Recorded" - Checklist

### Step 1: Verify Emulator Microphone is Enabled

1. **Open emulator extended controls:**
   - Click the three dots (`⋮`) on the right sidebar of the emulator
   - Select **Extended controls**

2. **Enable audio input:**
   - Go to **Microphone** section
   - Set it to **Virtual microphone** or **Back microphone**
   - Verify the **Allow use of host computer's mic** is checked

3. **Test the microphone:**
   - In emulator, open **Google Recorder** or **Google Assistant**
   - Try saying something to confirm the emulator picks it up

### Step 2: Install & Configure Google App

The Android Speech Recognition API requires Google app to be the default handler.

```bash
# Check if Google app is installed
adb shell pm list packages | grep google

# If Google app is not installed, you need to install it manually
# Download from: https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox
# Then install via:
# adb install /path/to/GoogleApp.apk
```

**Set Google as default speech recognizer:**
1. Open Settings → Apps → Default apps
2. Find "Speech services" or "Assist & voice input"
3. Ensure **Google** is selected

### Step 3: Verify App Permissions

1. **In the app, check microphone permission:**
   - Go to **Settings > Apps > SmartSpeak > Permissions**
   - Enable **Microphone**

2. **Check AndroidManifest.xml has these permissions:**
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```
   ✓ Your app already has these configured correctly.

### Step 4: Check STT Service Initialization

Enable debug logging in the STT service. Look for these log messages:

```
[STT] init available: true
[STT] requestAndCheck available: true
[STT] Starting listen with locale: en_US
[STT] Sound level: X.XX
[STT] Result: "your speech here"
```

**If you see:**
- ❌ `init available: false` → Step 2 (Install Google app)
- ❌ `Sound level: 0.0` (always) → Step 1 (Enable emulator microphone)
- ❌ No results → May need to check pauseFor/listenFor timing

### Step 5: Android API Level Considerations

The code uses `ListenMode.dictation` which works best on **Android 11+**.

If on Android 10 or below, try:

1. **Update Android API level in emulator** (create new AVD with API 33+)
2. Or modify [stt_service.dart] to use `ListenMode.confirmation`:
   ```dart
   listenMode: ListenMode.confirmation,  // Instead of dictation
   ```
   ⚠️ Note: Confirmation mode may hang on some emulators.

---

## Advanced Debugging

### Add Temporary Debug Screen

Create a debug screen to test STT directly without the full practice flow:

```dart
// In lib/core/widgets/stt_debug_widget.dart
class SttDebugWidget extends StatefulWidget {
  @override
  State<SttDebugWidget> createState() => _SttDebugWidgetState();
}

class _SttDebugWidgetState extends State<SttDebugWidget> {
  String _status = 'Ready';
  String _result = '';
  
  void _test() async {
    setState(() => _status = 'Listening...');
    try {
      final sttService = context.read<SttService>();
      final sub = sttService.listen().listen(
        (r) => setState(() => _result = r.recognizedWords),
        onError: (e) => setState(() => _status = 'Error: $e'),
        onDone: () => setState(() => _status = 'Done'),
      );
      await Future.delayed(Duration(seconds: 5));
      await sub.cancel();
    } catch (e) {
      setState(() => _status = 'Failed: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: _test, child: Text('Test STT')),
        Text(_status),
        Text(_result),
      ],
    );
  }
}
```

### Check Logcat for Errors

```bash
# Run while recording
adb logcat | grep -i speech
adb logcat | grep -i microphone
adb logcat | grep -i STT
```

---

## Solution Summary

| Problem | Solution |
|---------|----------|
| "No sound detected" | Enable emulator microphone in Extended Controls |
| "STT not available" | Install Google app, set as default recognizer |
| "Permission denied" | Grant microphone permission in app settings |
| "Listens but no results" | Use `ListenMode.confirmation` instead of `dictation` |
| "Hangs during listen" | Update to Android API 33+, or change listen mode |

---

## Next Steps

1. Run `SttDiagnostic.runFullDiagnostic()` to identify the exact issue
2. Follow the corresponding checklist item above
3. Rebuild and test: `flutter run`
4. If still failing, run: `adb logcat | grep STT` and share the output

