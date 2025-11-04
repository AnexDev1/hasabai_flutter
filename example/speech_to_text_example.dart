import 'dart:io';
import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

/// Example: How to use Speech-to-Text with Hasab AI
///
/// This example shows how to transcribe audio files using the Hasab AI Flutter SDK.
/// The SDK handles file upload automatically - you just need to provide the audio file.
void main() async {
  // Initialize Hasab AI
  final hasab = HasabAI(apiKey: 'YOUR_API_KEY');

  // Example 1: Basic transcription from file
  await transcribeFromFile(hasab);

  // Example 2: Transcribe and translate
  await transcribeAndTranslateFromFile(hasab);

  // Example 3: Get transcription history
  await getHistory(hasab);
}

/// Example 1: Basic transcription from audio file
Future<void> transcribeFromFile(HasabAI hasab) async {
  try {
    // Load your audio file (can be from any source)
    final audioFile = File('path/to/your/audio.m4a'); // or .mp3, .wav, .ogg

    final response = await hasab.speechToText.transcribe(
      audioFile,
      language: 'amh', // or 'orm', 'tir', 'eng', 'auto'
      translate: false,
      summarize: false,
      isMeeting: false,
      timestamps: false,
    );

    print('Transcription: ${response.text}');
    print('Language: ${response.language}');
    print('Confidence: ${response.confidence}');

    // If timestamps were requested, they would be in response.timestamps
    if (response.timestamps != null) {
      print('Timestamps: ${response.timestamps}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 2: Transcribe and translate from file
Future<void> transcribeAndTranslateFromFile(HasabAI hasab) async {
  try {
    final audioFile = File('path/to/your/audio.m4a');

    final response = await hasab.speechToText.transcribeAndTranslate(
      audioFile,
      targetLanguage: HasabLanguage.english,
      sourceLanguage:
          HasabLanguage.amharic, // optional, auto-detected if not provided
      summarize: false,
      isMeeting: false,
    );

    print('Original Text: ${response.text}');
    print('Translation: ${response.translation}');
    print('Summary: ${response.summary}');
    print('Language: ${response.language}');
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 3: Get transcription history
Future<void> getHistory(HasabAI hasab) async {
  try {
    final history = await hasab.speechToText.getTranscriptionHistory(page: 1);

    print('History: $history');
    // Process history data...
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 4: Using VoiceInputField widget (in Flutter UI)
/// This shows how to integrate voice recording directly in your Flutter app
/*
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final HasabAI hasab;

  const MyWidget({super.key, required this.hasab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoiceInputField(
        speechToTextService: hasab.speechToText,
        language: HasabLanguage.amharic,
        onTranscriptionComplete: (text) {
          print('Transcribed: $text');
          // Handle the transcribed text
        },
        decoration: const InputDecoration(
          labelText: 'Speak or type your message',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
*/
