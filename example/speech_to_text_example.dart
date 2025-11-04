import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

/// Example: How to use Speech-to-Text with Hasab AI
///
/// IMPORTANT: The Hasab AI API expects audio files to be already uploaded to S3.
/// You need to:
/// 1. Upload your audio file to S3 (or get it from another source)
/// 2. Get the S3 URL and key
/// 3. Pass them to the transcribe method
///
/// This example shows the expected usage pattern.
void main() async {
  // Initialize Hasab AI
  final hasab = HasabAI(apiKey: 'YOUR_API_KEY');

  // Example 1: Transcribe audio from S3 URL
  await transcribeFromUrl(hasab);

  // Example 2: Transcribe and translate
  await transcribeAndTranslateFromUrl(hasab);

  // Example 3: Get transcription history
  await getHistory(hasab);
}

/// Example 1: Basic transcription from S3 URL
Future<void> transcribeFromUrl(HasabAI hasab) async {
  try {
    // You need to have already uploaded the file to S3
    // These values come from your S3 upload response
    final audioUrl =
        'https://hasab.s3.amazonaws.com/audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3';
    final audioKey = 'audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3';

    final response = await hasab.speechToText.transcribe(
      audioUrl: audioUrl,
      audioKey: audioKey,
      language: 'amh', // Amharic
      translate: false,
      summarize: false,
      isMeeting: false,
    );

    print('Transcription: ${response.text}');
    print('Language: ${response.language}');

    // If timestamps were requested, they would be in response.timestamps
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 2: Transcribe and translate from S3 URL
Future<void> transcribeAndTranslateFromUrl(HasabAI hasab) async {
  try {
    final audioUrl =
        'https://hasab.s3.amazonaws.com/audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3';
    final audioKey = 'audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3';

    final response = await hasab.speechToText.transcribeAndTranslate(
      audioUrl: audioUrl,
      audioKey: audioKey,
      targetLanguage: HasabLanguage.english,
      sourceLanguage: HasabLanguage.amharic,
      summarize: true,
      isMeeting: true,
    );

    print('Original: ${response.text}');
    print('Translation: ${response.translation}');
    print('Summary: ${response.summary}');
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 3: Get transcription history
Future<void> getHistory(HasabAI hasab) async {
  try {
    final history = await hasab.speechToText.getTranscriptionHistory(page: 1);

    print('Total transcriptions: ${history['data']['total']}');
    print('Current page: ${history['data']['current_page']}');

    final transcriptions = history['data']['data'] as List<dynamic>;
    for (final item in transcriptions) {
      print('---');
      print('ID: ${item['id']}');
      print('Filename: ${item['original_filename']}');
      print('Transcription: ${item['transcription']}');
      print('Created: ${item['created_at']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/// Note: If you need to upload local files, you have two options:
///
/// 1. Implement your own S3 upload logic:
/// ```dart
/// Future<Map<String, String>> uploadToS3(File audioFile) async {
///   // Use AWS SDK or your backend's upload endpoint
///   // Return {'url': s3Url, 'key': s3Key}
/// }
/// ```
///
/// 2. Use a backend endpoint that handles both upload and transcription:
/// ```dart
/// // In your backend (Node.js, Python, etc.):
/// // POST /api/transcribe-file
/// // - Accept file upload
/// // - Upload to S3
/// // - Call Hasab AI with S3 URL
/// // - Return transcription
/// ```
