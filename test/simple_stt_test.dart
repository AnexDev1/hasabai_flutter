// Simple test that doesn't use Flutter - just pure Dart with Dio
import 'package:dio/dio.dart';

void main() async {
  print('🎤 Testing Hasab AI Speech-to-Text API\n');

  final dio = Dio();

  // Set up base options
  dio.options.baseUrl = 'https://api.hasab.co/api';
  dio.options.headers = {
    'Authorization': 'Bearer HASAB_KEY_we4C2GPjbWXB2RJ0B2dh5Cit1QL02I',
    'Accept': 'application/json',
  };

  try {
    // Test data from the documentation
    final body = {
      'url':
          'https://hasab.s3.amazonaws.com/audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3?response-content-type=audio&response-content-disposition=attachment%3B%20filename%3D%2235f90f42-6390-4f22-8e41-2245c2834fd9.mp3%22&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3ARKCU2R5ANLKWXX%2F20251031%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251031T130503Z&X-Amz-SignedHeaders=host&X-Amz-Expires=1800&X-Amz-Signature=e4276b1f55779211fdf0ee0922669ba1423e84a6f353c7554e27a705f061856c',
      'key': 'audios/original/35f90f42-6390-4f22-8e41-2245c2834fd9.mp3',
      'translate': 'true',
      'summarize': 'true',
      'is_meeting': 'true',
      'language': 'amh',
    };

    print('📤 Sending request to /upload-audio');
    print('📦 Body: $body\n');

    final response = await dio.post('/upload-audio', data: body);

    print('✅ Success! Status: ${response.statusCode}\n');
    print('📝 Response: ${response.data}\n');

    // Parse the response
    if (response.data['transcription'] != null) {
      print('🎯 Transcription: ${response.data['transcription']}\n');
    }

    if (response.data['translation'] != null &&
        response.data['translation'].toString().isNotEmpty) {
      print('🌐 Translation: ${response.data['translation']}\n');
    }

    if (response.data['summary'] != null &&
        response.data['summary'].toString().isNotEmpty) {
      print('📋 Summary: ${response.data['summary']}\n');
    }
  } on DioException catch (e) {
    print('❌ Error: ${e.message}');
    if (e.response != null) {
      print('📛 Response status: ${e.response?.statusCode}');
      print('📛 Response data: ${e.response?.data}');
    }
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}
