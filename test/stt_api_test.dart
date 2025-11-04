import 'package:hasab_ai_flutter/hasab_ai_flutter.dart';

void main() async {
  // Initialize Hasab AI
  final hasab = HasabAI(apiKey: 'HASAB_KEY_we4C2GPjbWXB2RJ0B2dh5Cit1QL02I');

  print('🎤 Hasab AI Speech-to-Text API Test\n');

  // Example from the documentation
  await testTranscription(hasab);
}

Future<void> testTranscription(HasabAI hasab) async {
  try {
    print('📤 Sending transcription request...\n');

    // These values should come from your S3 upload
    // In a real app, you would:
    // 1. Upload audio file to S3
    // 2. Get the URL and key from the upload response
    // 3. Pass them to this method
    final audioUrl =
        'https://hasab.s3.amazonaws.com/audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3?response-content-type=audio&response-content-disposition=attachment%3B%20filename%3D%2235f90f42-6390-4f22-8e41-2245c2834fd9.mp3%22&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3ARKCU2R5ANLKWXX%2F20251031%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251031T130503Z&X-Amz-SignedHeaders=host&X-Amz-Expires=1800&X-Amz-Signature=e4276b1f55779211fdf0ee0922669ba1423e84a6f353c7554e27a705f061856c';
    final audioKey = 'audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3';

    final response = await hasab.speechToText.transcribe(
      audioUrl: audioUrl,
      audioKey: audioKey,
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
