import 'dart:io';
import 'package:hasab_ai_flutter/src/hasab_api_client.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';
import 'package:hasab_ai_flutter/src/models/response_models.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';
import 'package:path_provider/path_provider.dart';

/// Service for text-to-speech conversion
class TextToSpeechService {
  final HasabApiClient _client;

  /// Create a new Text-to-Speech service
  TextToSpeechService(this._client);

  /// Convert text to speech audio file
  ///
  /// [text] The text to convert to speech
  /// [language] The target language for speech synthesis
  /// [outputPath] Optional custom output path for the audio file
  /// [voice] Optional voice ID to use
  /// [speed] Optional speech speed (0.5 to 2.0)
  /// [options] Additional options for synthesis
  ///
  /// Returns a [TextToSpeechResponse] with the path to the audio file
  ///
  /// Throws [HasabException] if the request fails
  /// Throws [HasabValidationException] if parameters are invalid
  Future<TextToSpeechResponse> synthesize(
    String text,
    HasabLanguage language, {
    String? outputPath,
    String? voice,
    double? speed,
    Map<String, dynamic>? options,
  }) async {
    // Validate text
    if (text.trim().isEmpty) {
      throw HasabValidationException(message: 'Text cannot be empty');
    }

    // Validate speed
    if (speed != null && (speed < 0.5 || speed > 2.0)) {
      throw HasabValidationException(
        message: 'Speed must be between 0.5 and 2.0',
        details: 'Provided speed: $speed',
      );
    }

    try {
      // Determine output path
      final savePath = outputPath ?? await _generateOutputPath();

      // Make API request and download audio using correct endpoint
      final audioPath = await _client.downloadFileFromPost(
        '/tts/synthesize',
        data: {
          'text': text,
          'language': language.code,
          if (voice != null) 'speaker_name': voice,
          ...?options,
        },
        outputFileName: savePath.split('/').last,
      );

      // Get file info
      final audioFile = File(audioPath);
      final fileSize = await audioFile.length();

      return TextToSpeechResponse(
        audioFilePath: audioPath,
        format: audioPath.split('.').last,
        fileSize: fileSize,
      );
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to synthesize speech',
        details: e.toString(),
      );
    }
  }

  /// Generate a default output path for the audio file
  Future<String> _generateOutputPath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/hasab_tts_$timestamp.mp3';
  }

  /// Get available voices for a language
  ///
  /// [language] Optional language to filter voices
  ///
  /// Returns a map of language codes to available speaker names
  Future<Map<String, List<String>>> getAvailableVoices([
    HasabLanguage? language,
  ]) async {
    try {
      final response = await _client.get(
        '/tts/speakers',
        queryParameters: language != null ? {'language': language.code} : null,
      );

      // API returns format: { "languages": { "amh": ["hanna", "selam"], ... }, "total_speakers": 15 }
      final languagesData = response['languages'] as Map<String, dynamic>;
      final voices = <String, List<String>>{};

      languagesData.forEach((langCode, speakersList) {
        if (speakersList is List) {
          voices[langCode] = speakersList.map((s) => s.toString()).toList();
        }
      });

      return voices;
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to get available voices',
        details: e.toString(),
      );
    }
  }

  /// Get supported output formats
  ///
  /// Returns a list of supported audio output formats
  Future<List<String>> getSupportedFormats() async {
    try {
      final response = await _client.get('/text-to-speech/formats');
      final formats = response['formats'] as List<dynamic>;
      return formats.map((f) => f.toString()).toList();
    } catch (e) {
      // Return default formats if API doesn't provide this endpoint
      return ['mp3', 'wav', 'ogg'];
    }
  }

  /// Convert text to speech and return raw audio bytes
  ///
  /// [text] The text to convert
  /// [language] The target language
  /// [voice] Optional voice ID
  /// [speed] Optional speech speed
  ///
  /// Returns the raw audio bytes
  Future<List<int>> synthesizeToBytes(
    String text,
    HasabLanguage language, {
    String? voice,
    double? speed,
  }) async {
    final response = await synthesize(
      text,
      language,
      voice: voice,
      speed: speed,
    );

    final audioFile = File(response.audioFilePath);
    return await audioFile.readAsBytes();
  }
}
