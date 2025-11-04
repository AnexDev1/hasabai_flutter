import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  final hasab = HasabAI(apiKey: 'HASAB_KEY_test');
  try {
    final speakers = await hasab.textToSpeech.getAvailableVoices();
    print('API returned speakers: $speakers');
  } catch (e) {
    print('Error: $e');
  }
}
