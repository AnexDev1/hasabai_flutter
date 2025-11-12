// Simple test using the Hasab AI Flutter SDK
import 'dart:io';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  print('🎤 Hasab AI Simple Speech-to-Text Test\n');

  // Use environment variable or skip if not available
  final apiKey = Platform.environment['HASAB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('⚠️  Skipping test: HASAB_API_KEY environment variable not set');
    return;
  }

  // Initialize Hasab AI
  final hasab = HasabAI(apiKey: apiKey);

  try {
    // Create a mock audio file for testing
    final testAudioFile = File('test_audio.m4a');
    if (!await testAudioFile.exists()) {
      await testAudioFile.writeAsBytes([0, 1, 2, 3, 4, 5]); // dummy data
    }

    print('📤 Sending transcription request with file upload');
    print('� File: ${testAudioFile.path}\n');

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

    print('🎯 Language: ${response.language.displayName}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
