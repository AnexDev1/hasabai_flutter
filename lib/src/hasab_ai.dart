import 'dart:io' show Platform;
import 'package:hasab_ai_flutter/src/hasab_api_client.dart';
import 'package:hasab_ai_flutter/src/services/speech_to_text.dart';
import 'package:hasab_ai_flutter/src/services/text_to_speech.dart';
import 'package:hasab_ai_flutter/src/services/translation.dart';
import 'package:hasab_ai_flutter/src/services/chat.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Main SDK class for Hasab AI
///
/// This is the primary entry point for all Hasab AI functionality.
/// Initialize once with your API key and use the service properties
/// to access speech-to-text, text-to-speech, translation, and chat features.
///
/// Example:
/// ```dart
/// final hasab = HasabAI(apiKey: 'your-api-key');
///
/// // Speech to text
/// final transcription = await hasab.speechToText.transcribe(audioFile);
///
/// // Text to speech
/// final audio = await hasab.textToSpeech.synthesize('Hello', HasabLanguage.english);
///
/// // Translation
/// final translation = await hasab.translation.translate(
///   'Hello',
///   HasabLanguage.english,
///   HasabLanguage.amharic,
/// );
///
/// // Chat
/// final response = await hasab.chat.sendMessage('Hello!');
/// ```
class HasabAI {
  final HasabApiClient _client;

  /// Speech-to-text service
  late final SpeechToTextService speechToText;

  /// Text-to-speech service
  late final TextToSpeechService textToSpeech;

  /// Translation service
  late final TranslationService translation;

  /// Chat service
  late final ChatService chat;

  /// Create a new Hasab AI instance
  ///
  /// [apiKey] Your Hasab AI API key
  /// [baseUrl] Optional custom base URL (defaults to https://hasab.co/api/v1)
  HasabAI({required String apiKey}) : _client = HasabApiClient(apiKey: apiKey) {
    speechToText = SpeechToTextService(_client);
    textToSpeech = TextToSpeechService(_client);
    translation = TranslationService(_client);
    chat = ChatService(_client);
  }

  /// Create a new Hasab AI instance using environment variables
  ///
  /// Reads API key from HASAB_API_KEY environment variable
  /// Reads base URL from HASAB_API_BASE_URL environment variable (optional)
  ///
  /// Throws [HasabException] if HASAB_API_KEY is not set
  factory HasabAI.fromEnvironment() {
    final apiKey = Platform.environment['HASAB_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw HasabException(
        message:
            'HASAB_API_KEY environment variable is not set. '
            'Please set it or use HasabAI(apiKey: "your-key") constructor.',
        statusCode: 500,
      );
    }

    return HasabAI(apiKey: apiKey);
  }

  /// Dispose and clean up resources
  void dispose() {
    _client.close();
  }
}
