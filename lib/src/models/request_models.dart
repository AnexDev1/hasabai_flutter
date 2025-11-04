import 'dart:io';
import 'language.dart';

/// Base request model
abstract class HasabRequest {
  Map<String, dynamic> toJson();
}

/// Request model for speech-to-text conversion
class SpeechToTextRequest implements HasabRequest {
  /// Audio file to transcribe
  final File audioFile;

  /// Language of the audio (optional, auto-detected if not provided)
  final HasabLanguage? language;

  /// Additional options
  final Map<String, dynamic>? options;

  SpeechToTextRequest({required this.audioFile, this.language, this.options});

  @override
  Map<String, dynamic> toJson() {
    return {
      if (language != null) 'language': language!.code,
      if (options != null) ...options!,
    };
  }
}

/// Request model for text-to-speech conversion
class TextToSpeechRequest implements HasabRequest {
  /// Text to convert to speech
  final String text;

  /// Target language for speech synthesis
  final HasabLanguage language;

  /// Voice settings (optional)
  final String? voice;

  /// Speed of speech (0.5 to 2.0)
  final double? speed;

  /// Additional options
  final Map<String, dynamic>? options;

  TextToSpeechRequest({
    required this.text,
    required this.language,
    this.voice,
    this.speed,
    this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'language': language.code,
      if (voice != null) 'voice': voice,
      if (speed != null) 'speed': speed,
      if (options != null) ...options!,
    };
  }
}

/// Request model for translation
class TranslationRequest implements HasabRequest {
  /// Text to translate
  final String text;

  /// Source language
  final HasabLanguage fromLanguage;

  /// Target language
  final HasabLanguage toLanguage;

  /// Additional options
  final Map<String, dynamic>? options;

  TranslationRequest({
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'from': fromLanguage.code,
      'to': toLanguage.code,
      if (options != null) ...options!,
    };
  }
}

/// Request model for chat message
class ChatRequest implements HasabRequest {
  /// Message to send to the AI
  final String message;

  /// Conversation ID for continuing a conversation (optional)
  final String? conversationId;

  /// System prompt or context (optional)
  final String? systemPrompt;

  /// Additional options
  final Map<String, dynamic>? options;

  ChatRequest({
    required this.message,
    this.conversationId,
    this.systemPrompt,
    this.options,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (options != null) ...options!,
    };
  }
}
