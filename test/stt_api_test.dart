import 'dart:io';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  // Use environment variable or skip if not available
  final apiKey = Platform.environment['HASAB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('⚠️  Skipping test: HASAB_API_KEY environment variable not set');
    return;
  }

  // Initialize Hasab AI
  final hasab = HasabAI(apiKey: apiKey);

  print('🎤 Hasab AI Speech-to-Text API Test\n');

  // Example from the documentation
  await testTranscription(hasab);
}

Future<void> testTranscription(HasabAI hasab) async {
  try {
    print('📤 Sending transcription request...\n');

    // For testing, we'll create a dummy audio file
    // In a real test, you'd use a real audio file
    final testAudioFile = File('test_audio.m4a');

    // If test file doesn't exist, create a dummy one for testing
    if (!await testAudioFile.exists()) {
      // Create a minimal test file (this won't work for real transcription)
      await testAudioFile.writeAsBytes([0, 1, 2, 3, 4, 5]); // dummy data
      print(
        '⚠️  Created dummy test file. Real tests should use actual audio files.\n',
      );
    }

    final response = await hasab.speechToText.transcribe(
      testAudioFile,
      language: 'amh',
      translate: true,
      summarize: true,
      isMeeting: true,
    );

    print('✅ Success!\n');
    print('📝 Transcription: ${response.text}\n');

    if (response.translation != null && response.translation!.isNotEmpty) {
      print('🌐 Translation: ${response.translation}\n');
    }

    if (response.summary != null && response.summary!.isNotEmpty) {
      print('📋 Summary: ${response.summary}\n');
    }

    if (response.audioUrl != null) {
      print('🔗 Audio URL: ${response.audioUrl}\n');
    }

    print('🎯 Language: ${response.language.displayName}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
