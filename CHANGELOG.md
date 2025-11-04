# Changelog

All notable changes to the Hasab AI Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-04

### Added
- Initial release of Hasab AI Flutter SDK
- **Speech-to-Text Service**: Convert audio files to text with support for Amharic, Oromo, Tigrinya, and English
  - Auto-detect language functionality
  - Support for multiple audio formats
  - Streaming transcription support (experimental)
- **Text-to-Speech Service**: Convert text to natural-sounding speech
  - Multiple voice options
  - Adjustable speech speed (0.5x to 2.0x)
  - Custom output path support
- **Translation Service**: Translate text between supported languages
  - Auto-detect source language
  - Batch translation support
  - High-accuracy translations for Ethiopian languages
- **Chat Service**: Interact with Hasab AI's conversational AI
  - Conversation history management
  - Multi-turn conversations
  - Streaming responses support (experimental)
- **Audio Utilities**:
  - `AudioRecorder` for voice recording with pause/resume
  - `AudioPlayerHelper` for audio playback with full control
- **Prebuilt Widgets**:
  - `VoiceInputField`: Text field with voice recording and auto-transcription
  - `TranslateButton`: One-tap translation button
  - `ChatWidget`: Full-featured chat UI component
- **Error Handling**: Custom exception classes for better error management
  - `HasabException`
  - `HasabAuthenticationException`
  - `HasabNetworkException`
  - `HasabFileException`
  - `HasabValidationException`
- **Models**: Comprehensive request/response models with null-safety
- **Language Support**: Enum-based language management for type safety
- **Example App**: Complete demo application showcasing all features
- **Documentation**: Comprehensive README with examples and API reference

### Features
- ✅ Null-safe Dart code
- ✅ Full Flutter 3.x support
- ✅ Android and iOS platform support
- ✅ Proper error handling and validation
- ✅ Stream-based audio playback
- ✅ Permission handling for microphone and storage
- ✅ Automatic file cleanup
- ✅ Batch operations support
- ✅ Conversation management

### Developer Experience
- Clean and intuitive API design
- Rich documentation and examples
- Type-safe language handling
- Comprehensive error messages
- Easy integration with existing Flutter apps

## [Unreleased]

### Planned Features
- WebSocket support for real-time streaming
- Offline mode with caching
- Audio preprocessing and noise reduction
- Custom voice training support
- Multi-language batch operations
- Analytics and usage tracking
- Performance optimizations
- Additional Ethiopian languages support

---

For more information, visit [hasab.co](https://hasab.co)
