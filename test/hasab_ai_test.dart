import 'package:flutter_test/flutter_test.dart';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() {
  late HasabAI hasab;

  setUpAll(() {
    // Initialize with the actual API key
    hasab = HasabAI(apiKey: 'HASAB_KEY_zeU0WiO5jKwXXMb3wxjnmd3GtUOJ0i');
  });

  tearDownAll(() {
    hasab.dispose();
  });

  group('HasabAI SDK Tests', () {
    test('SDK initializes correctly', () {
      expect(hasab, isNotNull);
      expect(hasab.speechToText, isNotNull);
      expect(hasab.textToSpeech, isNotNull);
      expect(hasab.translation, isNotNull);
      expect(hasab.chat, isNotNull);
    });

    test('Language enum works correctly', () {
      expect(HasabLanguage.amharic.code, 'am');
      expect(HasabLanguage.oromo.code, 'om');
      expect(HasabLanguage.tigrinya.code, 'ti');
      expect(HasabLanguage.english.code, 'en');

      expect(HasabLanguage.fromCode('am'), HasabLanguage.amharic);
      expect(HasabLanguage.fromCode('EN'), HasabLanguage.english);
    });

    test('Translation service is accessible', () {
      expect(hasab.translation, isNotNull);
      expect(hasab.translation, isA<TranslationService>());
    });

    test('Chat service is accessible', () {
      expect(hasab.chat, isNotNull);
      expect(hasab.chat, isA<ChatService>());
    });

    test('Speech-to-text service is accessible', () {
      expect(hasab.speechToText, isNotNull);
      expect(hasab.speechToText, isA<SpeechToTextService>());
    });

    test('Text-to-speech service is accessible', () {
      expect(hasab.textToSpeech, isNotNull);
      expect(hasab.textToSpeech, isA<TextToSpeechService>());
    });

    // Integration tests (commented out to avoid actual API calls during testing)
    // Uncomment these when you want to test against the real API

    /*
    test('Translation works with real API', () async {
      final result = await hasab.translation.translate(
        'Hello',
        HasabLanguage.english,
        HasabLanguage.amharic,
      );

      expect(result, isNotNull);
      expect(result.translatedText, isNotEmpty);
      expect(result.fromLanguage, HasabLanguage.english);
      expect(result.toLanguage, HasabLanguage.amharic);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Chat works with real API', () async {
      final result = await hasab.chat.sendMessage('Hello');

      expect(result, isNotNull);
      expect(result.message, isNotEmpty);
      expect(result.conversationId, isNotEmpty);
      expect(result.messageId, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Language detection works', () async {
      final result = await hasab.translation.detectLanguage('ሰላም');

      expect(result, isNotNull);
      expect(result, HasabLanguage.amharic);
    }, timeout: const Timeout(Duration(seconds: 30)));
    */
  });

  group('Exception Tests', () {
    test('HasabException creates correctly', () {
      final exception = HasabException(
        message: 'Test error',
        statusCode: 400,
        details: {'key': 'value'},
      );

      expect(exception.message, 'Test error');
      expect(exception.statusCode, 400);
      expect(exception.details, isNotNull);
      expect(exception.toString(), contains('Test error'));
    });

    test('HasabAuthenticationException creates correctly', () {
      final exception = HasabAuthenticationException(
        message: 'Auth failed',
        statusCode: 401,
      );

      expect(exception, isA<HasabException>());
      expect(exception.message, 'Auth failed');
      expect(exception.statusCode, 401);
    });

    test('HasabValidationException creates correctly', () {
      final exception = HasabValidationException(
        message: 'Validation failed',
        details: 'Invalid input',
      );

      expect(exception, isA<HasabException>());
      expect(exception.message, 'Validation failed');
      expect(exception.details, 'Invalid input');
    });
  });

  group('Model Tests', () {
    test('ChatMessage creates and serializes correctly', () {
      final message = ChatMessage(
        content: 'Test message',
        role: 'user',
        messageId: '123',
        timestamp: DateTime(2025, 11, 4),
      );

      expect(message.content, 'Test message');
      expect(message.role, 'user');
      expect(message.messageId, '123');

      final json = message.toJson();
      expect(json['content'], 'Test message');
      expect(json['role'], 'user');

      final restored = ChatMessage.fromJson(json);
      expect(restored.content, message.content);
      expect(restored.role, message.role);
    });

    test('TranslationRequest creates correctly', () {
      final request = TranslationRequest(
        text: 'Hello',
        fromLanguage: HasabLanguage.english,
        toLanguage: HasabLanguage.amharic,
      );

      final json = request.toJson();
      expect(json['text'], 'Hello');
      expect(json['from'], 'en');
      expect(json['to'], 'am');
    });

    test('ChatRequest creates correctly', () {
      final request = ChatRequest(message: 'Hi', conversationId: 'conv-123');

      final json = request.toJson();
      expect(json['message'], 'Hi');
      expect(json['conversation_id'], 'conv-123');
    });
  });
}
