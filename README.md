# Hear & See Safe

Flutter app for children with visual and/or hearing impairments, with educational games, audio feedback, and strong accessibility controls. Supports Macedonian, English, and Albanian.

## Tech stack

- **Flutter** (Dart 3), Material 3, **Provider** for state
- **easy_localization** + JSON translations (`en`, `mk`, `sq`)
- **Voice & audio:** `flutter_tts`, `speech_to_text`, `audioplayers`, `just_audio`, `record`, `vibration`
- **Camera & ML:** `camera`, `image_picker`, **TensorFlow Lite** (`tflite_flutter`)
- **Networking:** `http` (cloud STT/TTS and intent handling where configured)
- **Storage:** `shared_preferences`, `path_provider`

## Features

- Language selection at launch; settings for **high contrast**, **large text**, voice assistant, vibration, and audio levels
- **Voice commands** to open activities by spoken name (orchestrated intent flow)
- **Learning:** Braille reference, illustrated picture book with audio
- **Games & activities:** number games (counting, operations, objects), **camera** recognition modes, spatial orientation, sound identification, cyber-safety quiz, sound memory, voice pong, melody memory, rhythm tap, interactive story choices
- **Accessibility-first UI:** scalable text (system + in-app), semantic labels, haptic feedback, themed screens with a dedicated high-contrast path

## Highlights

- Voice pipeline built around a **configurable stack** (on-device STT/TTS plus optional HTTP services for recognition and language understanding)
- **Clean separation** between UI, providers, services, and the voice subsystem (orchestrator, caching, language manager)
- Games share consistent **screen chrome** and accessibility utilities so behavior stays predictable across modules

## Setup

```bash
flutter pub get
flutter run
```

Use **Android** (device or emulator) for full camera, vibration, and TTS coverage; web builds are fine for UI work but camera and some TTS voices are limited in the browser.

For a short user-oriented guide in Macedonian, see **`README_KORISNIK_MK.md`**.
