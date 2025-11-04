import 'dart:io';
import 'package:hasab_ai_flutter/src/hasab_api_client.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';
import 'package:hasab_ai_flutter/src/models/response_models.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Service for speech-to-text conversion
class SpeechToTextService {
  final HasabApiClient _client;

  /// Create a new Speech-to-Text service
  SpeechToTextService(this._client);

  /// Convert audio file to text
  ///
  /// [audioFile] The audio file to transcribe
  /// [language] Optional language hint for transcription (default: "auto")
  /// [translate] Whether to translate the transcription (default: false)
  /// [summarize] Whether to generate a summary (default: false)
  /// [isMeeting] Whether this is a meeting recording (default: false)
  /// [timestamps] Whether to include timestamps in the response (default: false)
  ///
  /// Returns a [SpeechToTextResponse] with the transcribed text
  ///
  /// Throws [HasabException] if the request fails
  /// Throws [HasabFileException] if the file is invalid
  Future<SpeechToTextResponse> transcribe(
    File audioFile, {
    String language = 'auto',
    bool translate = false,
    bool summarize = false,
    bool isMeeting = false,
    bool timestamps = false,
  }) async {
    // Validate file exists
    if (!await audioFile.exists()) {
      throw HasabFileException(
        message: 'Audio file does not exist: ${audioFile.path}',
      );
    }

    // Validate file size (max 25MB)
    final fileSize = await audioFile.length();
    if (fileSize > 25 * 1024 * 1024) {
      throw HasabFileException(
        message: 'Audio file is too large. Maximum size is 25MB.',
        details:
            'File size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB',
      );
    }

    try {
      // All fields are REQUIRED by the API, including 'transcribe'
      final additionalFields = <String, dynamic>{
        'translate': translate,
        'summarize': summarize,
        'is_meeting': isMeeting,
        'language': language,
      };

      if (timestamps) {
        additionalFields['timestamps'] = true;
      }

      final response = await _client.uploadFile(
        '/upload-audio',
        audioFile,
        fileFieldName: 'audio',
        additionalFields: additionalFields,
      );

      return SpeechToTextResponse.fromJson(response);
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to transcribe audio',
        details: e.toString(),
      );
    }
  }

  /// Transcribe and translate audio file
  ///
  /// [audioFile] The audio file to transcribe and translate
  /// [targetLanguage] The language to translate to
  /// [sourceLanguage] The language of the audio (optional, auto-detected if not provided)
  /// [summarize] Whether to generate a summary (default: false)
  /// [isMeeting] Whether this is a meeting recording (default: false)
  ///
  /// Returns a [SpeechToTextResponse] with both transcription and translation
  ///
  /// Throws [HasabException] if the request fails
  /// Throws [HasabFileException] if the file is invalid
  Future<SpeechToTextResponse> transcribeAndTranslate(
    File audioFile, {
    required HasabLanguage targetLanguage,
    HasabLanguage? sourceLanguage,
    bool summarize = false,
    bool isMeeting = false,
  }) async {
    // Validate file exists
    if (!await audioFile.exists()) {
      throw HasabFileException(
        message: 'Audio file does not exist: ${audioFile.path}',
      );
    }

    // Validate file size (max 25MB)
    final fileSize = await audioFile.length();
    if (fileSize > 25 * 1024 * 1024) {
      throw HasabFileException(
        message: 'Audio file is too large. Maximum size is 25MB.',
        details:
            'File size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB',
      );
    }

    try {
      final additionalFields = <String, dynamic>{
        'translate': true, // Translation requested
        'summarize': summarize,
        'is_meeting': isMeeting,
        'language': targetLanguage.code,
      };

      if (sourceLanguage != null) {
        additionalFields['source_language'] = sourceLanguage.code;
      }

      final response = await _client.uploadFile(
        '/upload-audio',
        audioFile,
        fileFieldName: 'audio',
        additionalFields: additionalFields,
      );

      return SpeechToTextResponse.fromJson(response);
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to transcribe and translate audio',
        details: e.toString(),
      );
    }
  }

  /// Get transcription history
  ///
  /// [page] The page number to retrieve (default: 1)
  ///
  /// Returns a paginated list of transcription history
  Future<Map<String, dynamic>> getTranscriptionHistory({int page = 1}) async {
    try {
      return await _client.get('/audios', queryParameters: {'page': page});
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to get transcription history',
        details: e.toString(),
      );
    }
  }

  /// Get supported audio formats
  ///
  /// Returns a list of supported audio file formats
  Future<List<String>> getSupportedFormats() async {
    try {
      final response = await _client.get('/speech-to-text/formats');
      final formats = response['formats'] as List<dynamic>;
      return formats.map((f) => f.toString()).toList();
    } catch (e) {
      // Return default formats if API doesn't provide this endpoint
      return ['mp3', 'wav', 'ogg', 'm4a', 'flac', 'webm'];
    }
  }
}
