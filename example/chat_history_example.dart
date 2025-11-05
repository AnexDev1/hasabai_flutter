import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  final hasab = HasabAI(apiKey: 'YOUR_API_KEY');
  await getChatHistory(hasab);
}

Future<void> getChatHistory(HasabAI hasab) async {
  try {
    final response = await hasab.chat.getHistory();

    print('Found ${response.history.length} conversations:');

    for (final conversation in response.history) {
      print('\nConversation #${conversation.id}: ${conversation.title}');
      print('Created: ${conversation.createdAt}');
      print('Messages: ${conversation.messages.length}');

      for (final message in conversation.messages.take(2)) {
        final role = message.role == 'user' ? 'You' : 'Hasab AI';
        print(
          '  $role: ${message.content.substring(0, min(50, message.content.length))}${message.content.length > 50 ? '...' : ''}',
        );
      }

      if (conversation.messages.length > 2) {
        print('  ... and ${conversation.messages.length - 2} more messages');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

int min(int a, int b) => a < b ? a : b;
