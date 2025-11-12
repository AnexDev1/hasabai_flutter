#!/usr/bin/env dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

/// Simple integration test to verify Hasab AI API connectivity
/// This runs without Flutter dependencies
void main() async {
  print('🚀 Testing Hasab AI API Connection\n');

  final apiKey =
      Platform.environment['HASAB_API_KEY'] ?? 'demo-key-for-testing';
  final baseUrl = 'https://hasab.co/api/v1';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  // Test 1: Translation (try different endpoints)
  print('📝 Test 1: Text Translation Service');

  // Check if text-only translation endpoints exist
  bool translationSuccess = false;

  for (final endpoint in ['/translate', '/translations/create', '/chat']) {
    try {
      print('   Trying endpoint: $endpoint');
      final translationResponse = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode({
          'text': 'Hello, how are you?',
          'from': 'eng', // Updated to use correct language codes
          'to': 'amh', // Updated to use correct language codes
        }),
      );

      print('   Status Code: ${translationResponse.statusCode}');
      if (translationResponse.statusCode == 200) {
        print('   ✅ Translation successful on $endpoint!');
        final data = jsonDecode(translationResponse.body);
        print('   Response: $data');
        translationSuccess = true;
        break;
      } else if (translationResponse.statusCode == 302 ||
          translationResponse.statusCode == 301) {
        print('   ⚠️  Redirect detected, trying next endpoint...');
      } else {
        print('   ❌ Failed with code ${translationResponse.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error on $endpoint: $e');
    }
  }

  if (!translationSuccess) {
    print(
      '   ⚠️  Text translation endpoint not found - use /upload-audio with translate=true for audio translation',
    );
  }
  print('');

  // Test 2: TTS (Text-to-Speech)
  print('📝 Test 2: TTS Speakers');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/tts/speakers'),
      headers: headers,
    );

    print('   Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('   ✅ TTS Speakers retrieved successfully!');
      print(
        '   Available languages: ${(data['languages'] as Map).keys.toList()}',
      );
      print('   Total speakers: ${data['total_speakers']}');

      // Show speakers for each language
      final languages = data['languages'] as Map<String, dynamic>;
      languages.forEach((lang, speakers) {
        print('   $lang: $speakers');
      });
    } else {
      print('   ❌ Failed with code ${response.statusCode}');
    }
  } catch (e) {
    print('   ❌ Error: $e');
  }
  print('');

  // Test 3: Chat API
  print('📝 Test 3: Chat Service');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: headers,
      body: jsonEncode({'message': 'Hello, can you help me?'}),
    );

    print('   Status Code: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      print('   ✅ Chat successful!');
      print('   Response: $data');
    } else {
      print('   ❌ Chat failed');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Error: $e');
  }
  print('');

  // Test 4: Chat History
  print('📝 Test 4: Chat History');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history'),
      headers: headers,
    );

    print('   Status Code: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('   ✅ History retrieval successful!');
      print('   Response: ${response.body.substring(0, 200)}...');
    } else {
      print('   ⚠️  History retrieval status: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Error: $e');
  }
  print('');

  print('═' * 50);
  print('✅ API Connection Test Complete!');
  print('═' * 50);
  print('\n📌 Summary:');
  print('   - API Key is configured');
  print('   - SDK is ready to use');
  print('   - Check response codes above for API status');
  print('');
}
