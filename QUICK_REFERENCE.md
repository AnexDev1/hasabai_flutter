# Hasab AI Flutter SDK - Quick Reference Guide

## 🚀 Quick Start

```dart
// 1. Import the SDK
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

// 2. Initialize with your API key
final hasab = HasabAI(apiKey: 'your-api-key');

// 3. Use the services
final result = await hasab.speechToText.transcribe(audioFile);
```

## 📋 Table of Contents
- [Installation](#installation)
- [Services Overview](#services-overview)
- [Speech-to-Text](#speech-to-text)
- [Text-to-Speech](#text-to-speech)
- [Translation](#translation)
- [Chat](#chat)
- [Widgets](#widgets)
- [Utilities](#utilities)
- [Error Handling](#error-handling)

## 📦 Installation

Add to `pubspec.yaml`:
```yaml
dependencies:
  hasab_ai_flutter: ^1.0.0
```

Run:
```bash
flutter pub get
```

## 🎯 Services Overview

| Service | Purpose | Main Methods |
|---------|---------|--------------|
| `speechToText` | Audio → Text | `transcribe()`, `detectLanguage()` |
| `textToSpeech` | Text → Audio | `synthesize()`, `getAvailableVoices()` |
| `translation` | Text → Translated Text | `translate()`, `translateWithAutoDetect()` |
| `chat` | AI Conversation | `sendMessage()`, `getHistory()` |

## 🎤 Speech-to-Text

### Basic Usage
```dart
import 'dart:io';

final audioFile = File('path/to/audio.mp3');
final result = await hasab.speechToText.transcribe(audioFile);
print('Text: ${result.text}');
print('Language: ${result.language.displayName}');
print('Confidence: ${result.confidence}');
```

### With Language Hint
```dart
final result = await hasab.speechToText.transcribe(
  audioFile,
  language: HasabLanguage.amharic,
);
```

### Detect Language
```dart
final language = await hasab.speechToText.detectLanguage(audioFile);
print('Detected: ${language.displayName}');
```

### Get Supported Formats
```dart
final formats = await hasab.speechToText.getSupportedFormats();
print('Supported formats: $formats');
```

## 🔊 Text-to-Speech

### Basic Synthesis
```dart
final result = await hasab.textToSpeech.synthesize(
  'ሰላም ፣ እንደምን ነህ?',
  HasabLanguage.amharic,
);
print('Audio saved at: ${result.audioFilePath}');
```

### With Custom Settings
```dart
final result = await hasab.textToSpeech.synthesize(
  'Hello, how are you?',
  HasabLanguage.english,
  speed: 1.2,  // Faster speech
  outputPath: '/custom/path/audio.mp3',
);
```

### Get Available Voices
```dart
final voices = await hasab.textToSpeech.getAvailableVoices(
  HasabLanguage.amharic,
);
print('Available voices: $voices');
```

### Get Audio as Bytes
```dart
final bytes = await hasab.textToSpeech.synthesizeToBytes(
  'Hello',
  HasabLanguage.english,
);
// Use bytes directly without saving to file
```

## 🌍 Translation

### Basic Translation
```dart
final result = await hasab.translation.translate(
  'Hello World',
  HasabLanguage.english,
  HasabLanguage.amharic,
);
print('Translation: ${result.translatedText}');
print('Confidence: ${result.confidence}');
```

### Auto-Detect Source Language
```dart
final result = await hasab.translation.translateWithAutoDetect(
  'ሰላም',
  HasabLanguage.english,  // Target language
);
print('Detected from: ${result.fromLanguage.displayName}');
print('Translation: ${result.translatedText}');
```

### Detect Language Only
```dart
final language = await hasab.translation.detectLanguage('ሰላም');
print('Detected language: ${language.displayName}');
```

### Batch Translation
```dart
final results = await hasab.translation.translateBatch(
  ['Hello', 'Goodbye', 'Thank you'],
  HasabLanguage.english,
  HasabLanguage.amharic,
);
for (final result in results) {
  print('${result.originalText} → ${result.translatedText}');
}
```

## 💬 Chat

### Send a Message
```dart
final response = await hasab.chat.sendMessage('Tell me about Ethiopia');
print('AI: ${response.message}');
print('Conversation ID: ${response.conversationId}');
```

### Continue Conversation
```dart
final response = await hasab.chat.sendMessage(
  'Tell me more',
  conversationId: previousResponse.conversationId,
);
```

### Get Chat History
```dart
final history = await hasab.chat.getHistory(
  conversationId: conversationId,
  limit: 50,
);
for (final message in history.messages) {
  print('${message.role}: ${message.content}');
}
```

### Start New Conversation
```dart
final conversationId = await hasab.chat.startConversation(
  initialMessage: 'Hello!',
  systemPrompt: 'You are a helpful assistant.',
);
```

### Get All Conversations
```dart
final conversations = await hasab.chat.getConversations(limit: 10);
for (final conv in conversations) {
  print('Conversation: ${conv['conversation_id']}');
}
```

### Delete Conversation
```dart
final success = await hasab.chat.deleteConversation(conversationId);
```

### Clear All History
```dart
final success = await hasab.chat.clearAllHistory();
```

## 🎨 Widgets

### VoiceInputField
```dart
VoiceInputField(
  speechToTextService: hasab.speechToText,
  language: HasabLanguage.amharic,
  onTranscriptionComplete: (text) {
    print('User said: $text');
  },
  decoration: InputDecoration(
    labelText: 'Speak or type',
    border: OutlineInputBorder(),
    hintText: 'Press mic to record',
  ),
)
```

### TranslateButton
```dart
TranslateButton(
  translationService: hasab.translation,
  text: textToTranslate,
  fromLanguage: HasabLanguage.english,
  toLanguage: HasabLanguage.amharic,
  onTranslationComplete: (translatedText) {
    setState(() {
      _translation = translatedText;
    });
  },
  onError: (error) {
    print('Translation error: $error');
  },
  buttonText: 'Translate Now',
  icon: Icons.translate,
)
```

### ChatWidget
```dart
ChatWidget(
  chatService: hasab.chat,
  conversationId: 'optional-conversation-id',
  showTimestamps: true,
  inputPlaceholder: 'Type your message...',
  onMessageSent: (message) {
    print('Sent: $message');
  },
  onResponseReceived: (response) {
    print('Received: ${response.message}');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

## 🛠️ Utilities

### AudioRecorder

```dart
final recorder = AudioRecorder();

// Initialize
await recorder.initialize();

// Start recording
final recordingPath = await recorder.startRecording();

// Pause/Resume
await recorder.pauseRecording();
await recorder.resumeRecording();

// Stop and get path
final path = await recorder.stopRecording();

// Delete recording
await recorder.deleteRecording(path);

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

// Play from bytes
await player.playFromBytes(audioBytes);

// Control playback
await player.pause();
await player.play();
await player.stop();
await player.seek(Duration(seconds: 10));

// Adjust settings
await player.setSpeed(1.5);  // 1.5x speed
await player.setVolume(0.8);  // 80% volume
await player.setLooping(true);

// Listen to state
player.playerStateStream.listen((state) {
  print('Player state: $state');
});

player.positionStream.listen((position) {
  print('Position: $position');
});

// Cleanup
await player.dispose();
```

## 🔒 Error Handling

### Try-Catch Pattern
```dart
try {
  final result = await hasab.speechToText.transcribe(audioFile);
  print('Success: ${result.text}');
} on HasabAuthenticationException catch (e) {
  print('Auth error: ${e.message}');
  print('Status: ${e.statusCode}');
} on HasabNetworkException catch (e) {
  print('Network error: ${e.message}');
} on HasabFileException catch (e) {
  print('File error: ${e.message}');
} on HasabValidationException catch (e) {
  print('Validation error: ${e.message}');
} on HasabException catch (e) {
  print('Hasab error: ${e.message}');
  print('Details: ${e.details}');
} catch (e) {
  print('Unknown error: $e');
}
```

### Exception Types

| Exception | When It's Thrown |
|-----------|------------------|
| `HasabAuthenticationException` | Invalid API key or auth failure |
| `HasabNetworkException` | Network connectivity issues |
| `HasabFileException` | File read/write/access errors |
| `HasabValidationException` | Invalid parameters or data |
| `HasabException` | General SDK errors |

## 🌐 Supported Languages

```dart
// Available languages
HasabLanguage.amharic    // አማርኛ
HasabLanguage.oromo      // Oromoo
HasabLanguage.tigrinya   // ትግርኛ
HasabLanguage.english    // English

// Language properties
final language = HasabLanguage.amharic;
print(language.code);         // 'am'
print(language.displayName);  // 'Amharic'

// Get language from code
final lang = HasabLanguage.fromCode('am');

// Get all supported codes
final codes = HasabLanguage.supportedCodes;
```

## 📝 Best Practices

### 1. Initialize Once
```dart
// Good: Initialize once in your app
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final HasabAI _hasab;

  @override
  void initState() {
    super.initState();
    _hasab = HasabAI(apiKey: 'your-key');
  }

  @override
  void dispose() {
    _hasab.dispose();
    super.dispose();
  }
}
```

### 2. Handle Errors Gracefully
```dart
Future<void> performAction() async {
  try {
    final result = await hasab.translation.translate(...);
    // Handle success
  } catch (e) {
    // Show user-friendly error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Operation failed. Please try again.')),
    );
  }
}
```

### 3. Clean Up Resources
```dart
@override
void dispose() {
  hasab.dispose();
  recorder.dispose();
  player.dispose();
  super.dispose();
}
```

### 4. Use Widgets for Common Tasks
```dart
// Instead of managing recording/transcription manually
VoiceInputField(
  speechToTextService: hasab.speechToText,
  onTranscriptionComplete: (text) => handleText(text),
)
```

### 5. Validate Before API Calls
```dart
if (text.trim().isEmpty) {
  // Show error to user
  return;
}

final result = await hasab.translation.translate(...);
```

## 🔗 Additional Resources

- [Full Documentation](https://github.com/hasabai/hasab_ai_flutter)
- [API Reference](https://hasab.co/docs)
- [Example App](../example/main.dart)
- [Issue Tracker](https://github.com/hasabai/hasab_ai_flutter/issues)

## 💡 Tips & Tricks

1. **Batch Operations**: Use batch methods when translating multiple texts
2. **Caching**: Store frequently used translations locally
3. **Error Recovery**: Implement retry logic for network errors
4. **File Cleanup**: Delete temporary audio files after use
5. **Permissions**: Request permissions early in the app lifecycle
6. **Testing**: Use mock data during development to save API calls

---

Built with ❤️ for Ethiopian developers by Hasab AI
