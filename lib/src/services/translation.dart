import 'package:hasab_ai_flutter/src/hasab_api_client.dart';
import 'package:hasab_ai_flutter/src/models/language.dart';
import 'package:hasab_ai_flutter/src/models/response_models.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Service for text translation
class TranslationService {
  final HasabApiClient _client;

  /// Create a new Translation service
  TranslationService(this._client);

  /// Translate text from one language to another
  ///
  /// [text] The text to translate (can be a single string or you can call multiple times)
  /// [fromLanguage] The source language
  /// [toLanguage] The target language
  /// [options] Additional options for translation
  ///
  /// Returns a [TranslationResponse] with the translated text
  ///
  /// Throws [HasabException] if the request fails
  /// Throws [HasabValidationException] if parameters are invalid
  Future<TranslationResponse> translate(
    String text,
    HasabLanguage fromLanguage,
    HasabLanguage toLanguage, {
    Map<String, dynamic>? options,
  }) async {
    // Validate text
    if (text.trim().isEmpty) {
      throw HasabValidationException(message: 'Text cannot be empty');
    }

    // Validate languages are different
    if (fromLanguage == toLanguage) {
      throw HasabValidationException(
        message: 'Source and target languages cannot be the same',
        details: 'Both are: ${fromLanguage.displayName}',
      );
    }

    try {
      // Use multipart form data as per API docs
      final responseData = await _client.postMultipart(
        '/translate',
        fields: {
          'text':
              '["${text.replaceAll('"', '\\"')}"]', // Send as JSON array string
          'source_language': fromLanguage.code,
          'target_language': toLanguage.code,
          ...?options,
        },
      );

      return TranslationResponse.fromJson(responseData);
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to translate text',
        details: e.toString(),
      );
    }
  }

  /// Translate multiple texts in a batch
  ///
  /// [texts] List of texts to translate
  /// [fromLanguage] The source language
  /// [toLanguage] The target language
  ///
  /// Returns a list of [TranslationResponse]
  Future<List<TranslationResponse>> translateBatch(
    List<String> texts,
    HasabLanguage fromLanguage,
    HasabLanguage toLanguage, {
    Map<String, dynamic>? options,
  }) async {
    if (texts.isEmpty) {
      throw HasabValidationException(message: 'Text list cannot be empty');
    }

    // Validate languages are different
    if (fromLanguage == toLanguage) {
      throw HasabValidationException(
        message: 'Source and target languages cannot be the same',
        details: 'Both are: ${fromLanguage.displayName}',
      );
    }

    try {
      // Escape quotes in texts and format as JSON array
      final escapedTexts = texts.map((t) => t.replaceAll('"', '\\"')).toList();
      final textArray = '["${escapedTexts.join('","')}"]';

      final responseData = await _client.postMultipart(
        '/translate',
        fields: {
          'text': textArray,
          'source_language': fromLanguage.code,
          'target_language': toLanguage.code,
          ...?options,
        },
      );

      // Parse array of translations
      if (responseData['translations'] is List) {
        return (responseData['translations'] as List)
            .map(
              (t) => TranslationResponse.fromJson(
                Map<String, dynamic>.from(t as Map),
              ),
            )
            .toList();
      }

      // If single response, wrap in list
      return [TranslationResponse.fromJson(responseData)];
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to translate batch',
        details: e.toString(),
      );
    }
  }

  /// Auto-detect source language and translate to target language
  ///
  /// Note: Direct text translation is not supported by Hasab AI API.
  /// This method will throw an exception.
  Future<TranslationResponse> translateWithAutoDetect(
    String text,
    HasabLanguage toLanguage, {
    Map<String, dynamic>? options,
  }) async {
    throw HasabException(
      message: 'Direct text translation is not supported by Hasab AI API',
      details:
          'Use the speech-to-text service with an audio file and translate: true parameter.',
      statusCode: 501,
    );
  }

  /// Get translation history
  ///
  /// [page] Page number for pagination (default: 1)
  ///
  /// Returns a paginated list of translation history
  Future<Map<String, dynamic>> getTranslationHistory({int page = 1}) async {
    try {
      final response = await _client.get(
        '/translations',
        queryParameters: {'page': page},
      );

      return response;
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to get translation history',
        details: e.toString(),
      );
    }
  }

  /// Detect the language of a text
  ///
  /// Note: Language detection endpoint is not documented in Hasab AI API.
  /// This method will throw an exception.
  Future<HasabLanguage> detectLanguage(String text) async {
    throw HasabException(
      message: 'Language detection is not supported by Hasab AI API',
      details: 'This feature is not available in the current API.',
      statusCode: 501,
    );
  }

  /// Get supported language pairs for translation
  ///
  /// Returns a map of source languages to their supported target languages
  Future<Map<HasabLanguage, List<HasabLanguage>>>
  getSupportedLanguagePairs() async {
    try {
      final response = await _client.get('/translate/supported-pairs');

      final pairs = <HasabLanguage, List<HasabLanguage>>{};
      final data = response['pairs'] as Map<String, dynamic>;

      for (final entry in data.entries) {
        final source = HasabLanguage.fromCode(entry.key);
        final targets = (entry.value as List<dynamic>)
            .map((code) => HasabLanguage.fromCode(code.toString()))
            .toList();
        pairs[source] = targets;
      }

      return pairs;
    } catch (e) {
      // Return default pairs if API doesn't provide this endpoint
      // All Ethiopian languages can translate to each other
      return {
        for (final lang in HasabLanguage.values)
          lang: HasabLanguage.values.where((l) => l != lang).toList(),
      };
    }
  }
}
