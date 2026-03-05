# SmartSpeak (Flutter / Material 3)

## Overview
SmartSpeak is an English pronunciation practice app built with Flutter (Material 3). It supports **word** and **phrase** practice, **speech-to-text** capture, **text-to-speech** playback, **microphone calibration** (ambient + voice thresholds stored locally), **environment noise detection**, and **explainable rule-based scoring** (“SmartSpeak Score”).

## Features
- Roleplay conversation practice (partner TTS line → your turn to speak)
- Conversation scenarios (Easy/Medium/Hard) with 10 user turns each (select prompt → listen (TTS) → record (STT) → score → feedback)
- Speech-to-Text (STT): uses the device speech services via `speech_to_text`
- Text-to-Speech (TTS): `flutter_tts`
- Microphone calibration:
  - Ambient noise sampling
  - Voice sampling
  - Personalized thresholds stored locally (`shared_preferences`)
- Environment noise detection:
  - Real-time dB meter
  - “Too noisy” / “Environment OK” feedback
- Visual feedback:
  - Large circular microphone button
  - Waveform animation while recording (driven by live dB stream)
  - Circular animated **SmartSpeak Score** indicator
  - Word-level highlights (green = credited word, red = missing/incorrect order, gray = extra words)
- Scoring & analysis (rule-based, explainable):
  - Credits only expected words spoken **in order**
  - Penalizes extra/unnecessary words
  - Word accuracy %
  - Fluency: filler detection + pause stats (total/longest) from STT partial-result timing

## Packages / APIs Used
- State management: `provider`
- Storage: `shared_preferences`
- Permissions: `permission_handler`
- Speech-to-Text: `speech_to_text`
- Text-to-Speech: `flutter_tts`
- Noise / microphone level: `noise_meter`

> Note: STT is provided by the device speech services. On many Android devices it can work offline **if** offline speech packs are installed; otherwise it may require network.

## How to Run
1. Install Flutter and Android SDK (Flutter stable recommended).
2. From the project root:
   ```bash
   flutter pub get
   flutter run
   ```

## Android Notes (priority)
- Required permissions (already configured in `android/app/src/main/AndroidManifest.xml`):
  - `RECORD_AUDIO`
  - `INTERNET` (may be required by device speech service, depending on offline availability)
- Recommended test:
  - Real device (preferred)
  - Emulator also works but STT quality may vary.

## Calibration Data
Calibration is stored locally in `SharedPreferences`:
- `ambientDbMean`, `ambientDbStd`
- `voiceDbMean`, `voiceDbStd`
- Derived thresholds used for environment checks

## Scoring Method (Explainable)
Given:
- Expected words list (normalized)
- Spoken words list (normalized) from STT

We compute:
- **In-order matches**: scan spoken words left-to-right, only credit an expected word when it appears in correct order.
- **Extra words**: spoken words not used for matching (excluding fillers)
- **Accuracy** = matchedExpected / expectedCount
- **Penalty** = extraCount / max(1, expectedCount)
- **SmartSpeak Score** = clamp( round(100 * (0.75*accuracy + 0.25*(1-penalty))) )

Fluency:
- filler words count (uh/um/uhm/umm/hmm/ah/er)
- pause durations estimated from STT partial updates:
  - total pauses (sum of silence gaps above threshold)
  - longest pause

## Testing Notes
- Android testing is prioritized. Run:
  ```bash
  flutter test
  ```
- If STT permissions are denied, use the in-app permission prompt or enable microphone permission in system settings.


## Web Note
If you run on Chrome/Web, microphone dB metering is not supported by this build (Android is prioritized). The app will still compile and run.
