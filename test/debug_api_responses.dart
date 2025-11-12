import 'dart:io';
import 'package:hasab_ai_flutter/src/hasab_ai.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';

/// Debug script to see actual API responses
void main() async {
  // Use environment variable or skip if not available
  final apiKey = Platform.environment['HASAB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print(
      '⚠️  Skipping debug script: HASAB_API_KEY environment variable not set',
    );
    return;
  }

  final hasab = HasabAI(apiKey: apiKey);

  print('\n=== Testing Chat ===');
  try {
    final chatResponse = await hasab.chat.sendMessage('Hello');
    print('✅ Chat Response:');
    print('  Message: ${chatResponse.message}');
    print('  ConversationID: ${chatResponse.conversationId}');
    print('  Full object: $chatResponse');
  } catch (e) {
    print('❌ Chat Error: $e');
  }

  print('\n=== Testing Translation ===');
  try {
    final translationResponse = await hasab.translation.translate(
      'Hello',
      HasabLanguage.english,
      HasabLanguage.amharic,
    );
    print('✅ Translation Response:');
    print('  Translated: ${translationResponse.translatedText}');
    print('  From: ${translationResponse.fromLanguage.displayName}');
    print('  To: ${translationResponse.toLanguage.displayName}');
    print('  Full object: $translationResponse');
  } catch (e) {
    print('❌ Translation Error: $e');
  }

  print('\n=== Done ===');
}
