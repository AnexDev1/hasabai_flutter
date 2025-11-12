# Hasab AI Flutter SDK

A comprehensive Flutter SDK for **Hasab AI** - providing speech-to-text, text-to-speech, translation, and chat capabilities for Ethiopian languages.

[![pub package](https://img.shields.io/pub/v/hasab_ai_flutter.svg)](https://pub.dev/packages/hasab_ai_flutter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🌟 Features

- **Speech-to-Text**: Convert voice recordings to text with support for Amharic, Oromo, Tigrinya, and English
- **Text-to-Speech**: Generate natural-sounding speech from text in multiple Ethiopian languages
- **Translation**: Translate between supported languages with high accuracy
- **Chat**: Interact with Hasab AI's conversational AI
- **Prebuilt Widgets**: Ready-to-use Flutter widgets for common tasks
- **Streaming Support**: Real-time transcription and chat responses (where supported)
- **Null-Safe**: Fully null-safe Dart code

## 🚀 Supported Languages

- 🇪🇹 **Amharic** (አማርኛ)
- 🇪🇹 **Oromo** (Oromoo)
- 🇪🇹 **Tigrinya** (ትግርኛ)
- 🇬🇧 **English**

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hasab_ai_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🔑 Getting Started

### 1. Get Your API Key

Sign up at [hasab.co](https://hasab.co) to get your API key.

### 2. Environment Setup (Recommended)

For security, we recommend using environment variables instead of hardcoding API keys:

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your API key:
   ```env
   HASAB_API_KEY=your_actual_api_key_here
   ```

3. Initialize the SDK using environment variables:
   ```dart
   import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

   // Initialize using environment variables (recommended)
   final hasab = HasabAI.fromEnvironment();
   ```

### 3. Direct Initialization (Alternative)

You can also initialize directly with your API key:

```dart
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

// Initialize with API key directly
final hasab = HasabAI(apiKey: 'your-api-key-here');
```

### 3. Start Using!

```dart
// Speech to Text
final audioFile = File('path/to/audio.mp3');
final transcription = await hasab.speechToText.transcribe(audioFile);
print('Transcribed: ${transcription.text}');

// Text to Speech
final audio = await hasab.textToSpeech.synthesize(
  'ሰላም ፤ እንደምን ነህ?',
  HasabLanguage.amharic,
);
print('Audio saved at: ${audio.audioFilePath}');

// Translation
final translation = await hasab.translation.translate(
  'Hello, how are you?',
  HasabLanguage.english,
  HasabLanguage.amharic,
);
print('Translation: ${translation.translatedText}');

// Chat
final response = await hasab.chat.sendMessage('Tell me about Ethiopia');
print('AI: ${response.message}');
```

## 📱 Platform Setup

### Android

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Add these to your `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice recording</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access</string>
```

## 🎨 Prebuilt Widgets

### VoiceInputField

A text field with voice recording and automatic transcription:

```dart
VoiceInputField(
  speechToTextService: hasab.speechToText,
  onTranscriptionComplete: (text) {
    print('User said: $text');
  },
  decoration: InputDecoration(
    labelText: 'Speak or type...',
    border: OutlineInputBorder(),
  ),
)
```

### TranslateButton

A button that translates text with a single tap:

```dart
TranslateButton(
  translationService: hasab.translation,
  text: 'Hello World',
  fromLanguage: HasabLanguage.english,
  toLanguage: HasabLanguage.amharic,
  onTranslationComplete: (translatedText) {
    print('Translated: $translatedText');
  },
)
```

### ChatWidget

A full-featured chat interface:

```dart
ChatWidget(
  chatService: hasab.chat,
  showTimestamps: true,
  onMessageSent: (message) {
    print('Sent: $message');
  },
  onResponseReceived: (response) {
    print('AI: ${response.message}');
  },
)
```

## 📚 Detailed Usage

### Speech-to-Text

```dart
// Basic transcription
final result = await hasab.speechToText.transcribe(audioFile);

// With language hint
final result = await hasab.speechToText.transcribe(
  audioFile,
  language: HasabLanguage.amharic,
);

// Detect language
final language = await hasab.speechToText.detectLanguage(audioFile);
print('Detected language: ${language.displayName}');

// Get supported formats
final formats = await hasab.speechToText.getSupportedFormats();
print('Supported: $formats');
```

### Text-to-Speech

```dart
// Basic synthesis
final audio = await hasab.textToSpeech.synthesize(
  'ሰላም',
  HasabLanguage.amharic,
);

// With custom settings
final audio = await hasab.textToSpeech.synthesize(
  'Hello',
  HasabLanguage.english,
  speed: 1.2,
  outputPath: '/custom/path/audio.mp3',
);

// Get available voices
final voices = await hasab.textToSpeech.getAvailableVoices(
  HasabLanguage.amharic,
);

// Get audio as bytes
final bytes = await hasab.textToSpeech.synthesizeToBytes(
  'Hello',
  HasabLanguage.english,
);
```

### Translation

```dart
// Basic translation
final result = await hasab.translation.translate(
  'Hello',
  HasabLanguage.english,
  HasabLanguage.amharic,
);

// Auto-detect source language
final result = await hasab.translation.translateWithAutoDetect(
  'ሰላም',
  HasabLanguage.english,
);

// Detect language
final language = await hasab.translation.detectLanguage('ሰላም');

// Batch translation
final results = await hasab.translation.translateBatch(
  ['Hello', 'Goodbye', 'Thank you'],
  HasabLanguage.english,
  HasabLanguage.amharic,
);
```

### Chat

```dart
// Send a message
final response = await hasab.chat.sendMessage('Hello!');

// Continue a conversation
final response = await hasab.chat.sendMessage(
  'Tell me more',
  conversationId: previousResponse.conversationId,
);

// Get chat history
final history = await hasab.chat.getHistory(
  conversationId: conversationId,
);

// Start a new conversation
final conversationId = await hasab.chat.startConversation(
  initialMessage: 'Hi there!',
);

// Get all conversations
final conversations = await hasab.chat.getConversations();

// Delete a conversation
await hasab.chat.deleteConversation(conversationId);
```

## 🎙️ Audio Utilities

### AudioRecorder

```dart
final recorder = AudioRecorder();
await recorder.initialize();

// Start recording
final path = await recorder.startRecording();

// Stop recording
final recordingPath = await recorder.stopRecording();

// Pause/Resume
await recorder.pauseRecording();
await recorder.resumeRecording();

// Cleanup
await recorder.dispose();
```

### AudioPlayerHelper

```dart
final player = AudioPlayerHelper();

// Play from file
await player.playFromFile('/path/to/audio.mp3');

// Play from URL
await player.playFromUrl('https://example.com/audio.mp3');

// Control playback
await player.pause();
await player.play();
await player.stop();
await player.seek(Duration(seconds: 10));

// Set speed and volume
await player.setSpeed(1.5);
await player.setVolume(0.8);

// Listen to state
player.playerStateStream.listen((state) {
  print('Player state: $state');
});

// Cleanup
await player.dispose();
```

## 🔒 Error Handling

```dart
try {
  final result = await hasab.speechToText.transcribe(audioFile);
  print('Success: ${result.text}');
} on HasabAuthenticationException catch (e) {
  print('Authentication failed: $e');
} on HasabNetworkException catch (e) {
  print('Network error: $e');
} on HasabFileException catch (e) {
  print('File error: $e');
} on HasabValidationException catch (e) {
  print('Validation error: $e');
} on HasabException catch (e) {
  print('Hasab error: $e');
}
```

## 🏗️ Project Structure

```
lib/
  hasab_ai_flutter.dart       # Main export file
  src/
    hasab_ai.dart              # Main SDK class
    hasab_api_client.dart      # HTTP client
    services/
      speech_to_text.dart
      text_to_speech.dart
      translation.dart
      chat.dart
    models/
      language.dart
      request_models.dart
      response_models.dart
      hasab_exception.dart
    utils/
      audio_recorder.dart
      audio_player.dart
    widgets/
      voice_input_field.dart
      translate_button.dart
      chat_widget.dart
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Hasab AI Website](https://hasab.co)
- [API Documentation](https://hasab.co/docs)
- [GitHub Repository](https://github.com/hasabai/hasab_ai_flutter)

## 💬 Support

For support, email support@hasab.co or join our community on [LinkedIn](https://www.linkedin.com/company/hasabai/).

## 🙏 Acknowledgments

Built with ❤️ for the Ethiopian developer community.

---

Made with 🇪🇹 by the Hasab AI Team

