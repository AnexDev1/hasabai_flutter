import 'dart:io';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  // Test STT with the same parameters as the curl command
  final hasab = HasabAI(apiKey: 'HASAB_KEY_test');

  try {
    // Use a test audio file (you would replace this with a real file)
    final audioFile = File('test_audio.m4a');

    if (!await audioFile.exists()) {
      print('❌ Test audio file not found. Please create test_audio.m4a');
      return;
    }

    print('🔄 Testing STT with curl-equivalent parameters...');

    final response = await hasab.speechToText.transcribe(
      audioFile,
      language: 'eng', // matches curl: language=eng
      translate: true, // matches curl: translate=true
      summarize: false, // matches curl: summarize=false
      isMeeting: false, // matches curl: is_meeting=false
    );

    print('✅ STT Success!');
    print('📝 Text: ${response.text}');
    print('🌐 Language: ${response.language.displayName}');
    if (response.translation != null) {
      print('🔄 Translation: ${response.translation}');
    }
    if (response.summary != null) {
      print('📋 Summary: ${response.summary}');
    }
  } catch (e) {
    print('❌ STT Failed: $e');
  }
}
