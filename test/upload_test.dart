// Test to see what the API actually expects
import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  print('🧪 Testing Hasab AI Upload Endpoint\n');

  // Use environment variable or skip if not available
  final apiKey = Platform.environment['HASAB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print(
      '⚠️  Skipping upload test: HASAB_API_KEY environment variable not set',
    );
    return;
  }

  final dio = Dio();
  dio.options.baseUrl = 'https://api.hasab.co/api';
  dio.options.headers = {
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
  };

  // Enable logging
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      error: true,
    ),
  );

  // Test 1: Try uploading with just the audio file
  print('\n📤 Test 1: Upload with only audio file\n');
  try {
    // Create a dummy audio file for testing
    final tempFile = File('test_audio.m4a');
    await tempFile.writeAsBytes([0, 1, 2, 3]); // Dummy data

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        tempFile.path,
        filename: 'test.m4a',
      ),
    });

    final response1 = await dio.post('/upload-audio', data: formData);
    print('✅ Response 1: ${response1.data}');

    await tempFile.delete();
  } catch (e) {
    if (e is DioException) {
      print('❌ Error 1: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
    }
  }

  // Test 2: Try with all parameters
  print('\n📤 Test 2: Upload with all parameters\n');
  try {
    final tempFile = File('test_audio.m4a');
    await tempFile.writeAsBytes([0, 1, 2, 3]); // Dummy data

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        tempFile.path,
        filename: 'test.m4a',
      ),
      'translate': false,
      'summarize': false,
      'language': 'eng',
      'is_meeting': false,
    });

    final response2 = await dio.post('/upload-audio', data: formData);
    print('✅ Response 2: ${response2.data}');

    await tempFile.delete();
  } catch (e) {
    if (e is DioException) {
      print('❌ Error 2: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
    }
  }

  print('\n✅ Tests complete!');
}
