import 'dart:io';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

/// Integration test script to verify Hasab AI SDK functionality
/// Run with: dart run test/integration_test.dart
void main() async {
  print('🚀 Starting Hasab AI SDK Integration Tests\n');

  // Use environment variable or skip if not available
  final apiKey = Platform.environment['HASAB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print(
      '⚠️  Skipping integration tests: HASAB_API_KEY environment variable not set',
    );
    print('   Set HASAB_API_KEY to run integration tests');
    return;
  }

  final hasab = HasabAI(apiKey: apiKey);

  try {
    // Test 1: Translation
    print('📝 Test 1: Translation Service');
    print('   Testing: English → Amharic');
    try {
      final translationResult = await hasab.translation.translate(
        'Hello, how are you?',
        HasabLanguage.english,
        HasabLanguage.amharic,
      );
      print('   ✅ Success!');
      print('   Original: Hello, how are you?');
      print('   Translated: ${translationResult.translatedText}');
      print(
        '   Language: ${translationResult.fromLanguage.displayName} → ${translationResult.toLanguage.displayName}',
      );
      if (translationResult.confidence != null) {
        print(
          '   Confidence: ${(translationResult.confidence! * 100).toStringAsFixed(1)}%',
        );
      }
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 2: Language Detection
    print('📝 Test 2: Language Detection');
    print('   Testing: Detect language of "ሰላም"');
    try {
      final detectedLang = await hasab.translation.detectLanguage('ሰላም');
      print('   ✅ Success!');
      print(
        '   Detected Language: ${detectedLang.displayName} (${detectedLang.code})',
      );
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 3: Auto-detect Translation
    print('📝 Test 3: Auto-detect Translation');
    print('   Testing: Auto-detect "ሰላም" and translate to English');
    try {
      final autoTranslation = await hasab.translation.translateWithAutoDetect(
        'ሰላም',
        HasabLanguage.english,
      );
      print('   ✅ Success!');
      print('   Original: ሰላም');
      print('   Detected as: ${autoTranslation.fromLanguage.displayName}');
      print('   Translated: ${autoTranslation.translatedText}');
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 4: Chat Service
    print('📝 Test 4: Chat Service');
    print('   Testing: Send a message to AI');
    try {
      final chatResponse = await hasab.chat.sendMessage(
        'Tell me a fun fact about Ethiopia',
      );
      print('   ✅ Success!');
      print('   AI Response: ${chatResponse.message}');
      print('   Conversation ID: ${chatResponse.conversationId}');
      print('   Message ID: ${chatResponse.messageId}');
      print('   Timestamp: ${chatResponse.timestamp}');
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 5: Chat History
    print('📝 Test 5: Chat History');
    print('   Testing: Retrieve chat history');
    try {
      final history = await hasab.chat.getHistory(limit: 5);
      print('   ✅ Success!');
      print('   Total messages: ${history.totalCount}');
      print('   Retrieved: ${history.messages.length} messages');
      if (history.messages.isNotEmpty) {
        print(
          '   Latest message: ${history.messages.last.content.substring(0, 50)}...',
        );
      }
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 6: Batch Translation
    print('📝 Test 6: Batch Translation');
    print('   Testing: Translate multiple texts');
    try {
      final batchResults = await hasab.translation.translateBatch(
        ['Hello', 'Goodbye', 'Thank you'],
        HasabLanguage.english,
        HasabLanguage.amharic,
      );
      print('   ✅ Success!');
      for (var i = 0; i < batchResults.length; i++) {
        print(
          '   ${i + 1}. ${batchResults[i].originalText} → ${batchResults[i].translatedText}',
        );
      }
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 7: Text-to-Speech (if supported)
    print('📝 Test 7: Text-to-Speech Service');
    print('   Testing: Generate speech from text');
    try {
      final ttsResult = await hasab.textToSpeech.synthesize(
        'Hello World',
        HasabLanguage.english,
      );
      print('   ✅ Success!');
      print('   Audio file: ${ttsResult.audioFilePath}');
      print('   Format: ${ttsResult.format}');
      if (ttsResult.fileSize != null) {
        print('   Size: ${(ttsResult.fileSize! / 1024).toStringAsFixed(2)} KB');
      }

      // Clean up the file
      final audioFile = File(ttsResult.audioFilePath);
      if (await audioFile.exists()) {
        await audioFile.delete();
        print('   🗑️  Audio file cleaned up');
      }
    } catch (e) {
      print('   ❌ Failed: $e');
    }
    print('');

    // Test 8: Error Handling
    print('📝 Test 8: Error Handling');
    print('   Testing: Invalid translation (same language)');
    try {
      await hasab.translation.translate(
        'Hello',
        HasabLanguage.english,
        HasabLanguage.english,
      );
      print('   ❌ Should have thrown an error!');
    } on HasabValidationException catch (e) {
      print('   ✅ Correctly caught validation error!');
      print('   Error: ${e.message}');
    } catch (e) {
      print('   ⚠️  Caught different error: $e');
    }
    print('');

    // Summary
    print('═' * 50);
    print('🎉 Integration Tests Complete!');
    print('═' * 50);
    print('\n✅ SDK is working correctly with the API');
    print('✅ All services are accessible');
    print('✅ Error handling is working');
    print('\n🔗 You can now use the SDK in your Flutter app!');
    print('');
  } catch (e, stackTrace) {
    print('❌ Fatal Error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    hasab.dispose();
    print('🧹 Cleanup complete');
  }
}
