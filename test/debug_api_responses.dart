import '../lib/src/hasab_ai.dart';
import '../lib/src/models/language.dart';

/// Debug script to see actual API responses
void main() async {
  final hasab = HasabAI(apiKey: 'HASAB_KEY_we4C2GPjbWXB2RJ0B2dh5Cit1QL02I');

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
