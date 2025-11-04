import 'package:equatable/equatable.dart';
import 'language.dart';

/// Base response model
abstract class HasabResponse {
  factory HasabResponse.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclass');
  }

  Map<String, dynamic> toJson();
}

/// Response model for speech-to-text conversion
class SpeechToTextResponse extends Equatable implements HasabResponse {
  /// Transcribed text
  final String text;

  /// Detected or specified language
  final HasabLanguage language;

  /// Translation of the transcription (if translate was true)
  final String? translation;

  /// Summary of the transcription (if summarize was true)
  final String? summary;

  /// Timestamps for each segment (if timestamps was true)
  final List<Map<String, dynamic>>? timestamps;

  /// Audio URL from S3
  final String? audioUrl;

  /// Confidence score (0.0 to 1.0)
  final double? confidence;

  /// Processing duration in milliseconds
  final int? processingTime;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const SpeechToTextResponse({
    required this.text,
    required this.language,
    this.translation,
    this.summary,
    this.timestamps,
    this.audioUrl,
    this.confidence,
    this.processingTime,
    this.metadata,
  });

  factory SpeechToTextResponse.fromJson(Map<String, dynamic> json) {
    // Handle different possible response formats
    String text = '';
    String languageCode = 'eng';
    String? translation;
    String? summary;
    List<Map<String, dynamic>>? timestamps;
    String? audioUrl;

    // Check if this is an audio upload response
    if (json.containsKey('audio')) {
      final audio = json['audio'];
      if (audio is Map) {
        text = audio['transcription']?.toString() ?? '';
        translation = audio['translation']?.toString();
        summary = audio['summary']?.toString();
        audioUrl = audio['audio_url']?.toString();

        // Try to get language from the audio object or parent
        languageCode =
            audio['language']?.toString() ??
            json['source_language']?.toString() ??
            json['language']?.toString() ??
            'eng';
      }
    } else if (json.containsKey('transcription')) {
      // Top-level transcription field
      text = json['transcription']?.toString() ?? '';
      translation = json['translation']?.toString();
      summary = json['summary']?.toString();
      audioUrl = json['audio']?['audio_url']?.toString();
      languageCode =
          json['language']?.toString() ??
          json['source_language']?.toString() ??
          'eng';
    } else if (json.containsKey('text')) {
      text = json['text']?.toString() ?? '';
      translation = json['translation']?.toString();
      summary = json['summary']?.toString();
      languageCode = json['language']?.toString() ?? 'eng';
    } else if (json.containsKey('data')) {
      final data = json['data'];
      if (data is Map) {
        text =
            data['text']?.toString() ?? data['transcription']?.toString() ?? '';
        translation = data['translation']?.toString();
        summary = data['summary']?.toString();
        audioUrl = data['audio_url']?.toString();
        languageCode = data['language']?.toString() ?? 'eng';
      }
    }

    // Handle timestamps array
    if (json.containsKey('timestamp') && json['timestamp'] is List) {
      timestamps = (json['timestamp'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    return SpeechToTextResponse(
      text: text,
      language: HasabLanguage.fromCode(languageCode),
      translation: translation?.isEmpty ?? true ? null : translation,
      summary: summary?.isEmpty ?? true ? null : summary,
      timestamps: timestamps,
      audioUrl: audioUrl,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      processingTime: json['processing_time'] as int?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'language': language.code,
      if (translation != null) 'translation': translation,
      if (summary != null) 'summary': summary,
      if (timestamps != null) 'timestamps': timestamps,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (confidence != null) 'confidence': confidence,
      if (processingTime != null) 'processing_time': processingTime,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    text,
    language,
    translation,
    summary,
    timestamps,
    audioUrl,
    confidence,
    processingTime,
    metadata,
  ];
}

/// Response model for text-to-speech conversion
class TextToSpeechResponse extends Equatable implements HasabResponse {
  /// Path to the generated audio file
  final String audioFilePath;

  /// Audio format (e.g., 'mp3', 'wav')
  final String format;

  /// Audio duration in seconds
  final double? duration;

  /// File size in bytes
  final int? fileSize;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const TextToSpeechResponse({
    required this.audioFilePath,
    required this.format,
    this.duration,
    this.fileSize,
    this.metadata,
  });

  factory TextToSpeechResponse.fromJson(
    Map<String, dynamic> json,
    String filePath,
  ) {
    return TextToSpeechResponse(
      audioFilePath: filePath,
      format: json['format'] as String? ?? 'mp3',
      duration: json['duration'] != null
          ? (json['duration'] as num).toDouble()
          : null,
      fileSize: json['file_size'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'audio_file_path': audioFilePath,
      'format': format,
      if (duration != null) 'duration': duration,
      if (fileSize != null) 'file_size': fileSize,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    audioFilePath,
    format,
    duration,
    fileSize,
    metadata,
  ];
}

/// Response model for translation
class TranslationResponse extends Equatable implements HasabResponse {
  /// Translated text
  final String translatedText;

  /// Source language
  final HasabLanguage fromLanguage;

  /// Target language
  final HasabLanguage toLanguage;

  /// Original text
  final String? originalText;

  /// Confidence score (0.0 to 1.0)
  final double? confidence;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const TranslationResponse({
    required this.translatedText,
    required this.fromLanguage,
    required this.toLanguage,
    this.originalText,
    this.confidence,
    this.metadata,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    // Handle different possible response formats
    String translatedText = '';
    String? originalText;

    // Check if response has nested data.translation structure
    if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'] as Map;

      // Check for data.translation object
      if (data.containsKey('translation') && data['translation'] is Map) {
        final translation = data['translation'] as Map;
        translatedText = translation['translated_text']?.toString() ?? '';

        // Handle source_text as array or string
        final sourceText = translation['source_text'];
        if (sourceText is List && sourceText.isNotEmpty) {
          originalText = sourceText.first?.toString();
        } else if (sourceText is String) {
          originalText = sourceText;
        }
      } else {
        // Fallback to data level
        translatedText =
            data['translated_text']?.toString() ??
            data['translation']?.toString() ??
            '';
        originalText = data['source_text']?.toString();
      }
    }
    // Check if this is an audio upload response with translation
    else if (json.containsKey('audio')) {
      final audio = json['audio'];
      if (audio is Map) {
        translatedText = audio['translation']?.toString() ?? '';
        originalText = audio['transcription']?.toString();
      }
    } else if (json.containsKey('translated_text')) {
      translatedText = json['translated_text']?.toString() ?? '';
      originalText =
          json['source_text']?.toString() ?? json['original_text']?.toString();
    } else if (json.containsKey('translation')) {
      translatedText = json['translation']?.toString() ?? '';
      originalText =
          json['transcription']?.toString() ?? json['source_text']?.toString();
    }

    // Extract language codes from nested structure or top level
    String fromCode = 'eng';
    String toCode = 'eng';

    // Try nested data.translation first
    if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'] as Map;
      if (data.containsKey('translation') && data['translation'] is Map) {
        final translation = data['translation'] as Map;
        fromCode = translation['source_language']?.toString() ?? 'eng';
        toCode = translation['target_language']?.toString() ?? 'eng';
      }
    }

    // Fallback to top level
    if (fromCode == 'eng' && json.containsKey('source_language')) {
      fromCode = json['source_language']?.toString() ?? 'eng';
    } else if (fromCode == 'eng' && json.containsKey('from')) {
      fromCode = json['from']?.toString() ?? 'eng';
    }

    if (toCode == 'eng' && json.containsKey('target_language')) {
      toCode = json['target_language']?.toString() ?? 'eng';
    } else if (toCode == 'eng' && json.containsKey('to')) {
      toCode = json['to']?.toString() ?? 'eng';
    } else if (toCode == 'eng' && json.containsKey('language')) {
      toCode = json['language']?.toString() ?? 'eng';
    }

    return TranslationResponse(
      translatedText: translatedText,
      fromLanguage: HasabLanguage.fromCode(fromCode),
      toLanguage: HasabLanguage.fromCode(toCode),
      originalText: originalText,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'translated_text': translatedText,
      'from': fromLanguage.code,
      'to': toLanguage.code,
      if (originalText != null) 'original_text': originalText,
      if (confidence != null) 'confidence': confidence,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    translatedText,
    fromLanguage,
    toLanguage,
    originalText,
    confidence,
    metadata,
  ];
}

/// Response model for chat message
class ChatResponse extends Equatable implements HasabResponse {
  /// AI response message
  final String message;

  /// Conversation ID
  final String conversationId;

  /// Message ID
  final String messageId;

  /// Timestamp of the response
  final DateTime timestamp;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const ChatResponse({
    required this.message,
    required this.conversationId,
    required this.messageId,
    required this.timestamp,
    this.metadata,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where API returns nested response or content/role format
    String message;
    if (json.containsKey('content') && json.containsKey('role')) {
      // API returned {content: "...", role: "assistant"} format
      message = json['content']?.toString() ?? '';
    } else if (json.containsKey('message')) {
      // Standard format
      final messageData = json['message'];
      if (messageData is Map) {
        // Nested message object
        message = messageData['content']?.toString() ?? messageData.toString();
      } else {
        message = messageData?.toString() ?? '';
      }
    } else {
      message = '';
    }

    return ChatResponse(
      message: message,
      conversationId: json['conversation_id']?.toString() ?? '',
      messageId: json['message_id']?.toString() ?? '',
      timestamp: DateTime.parse(
        json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'conversation_id': conversationId,
      'message_id': messageId,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    message,
    conversationId,
    messageId,
    timestamp,
    metadata,
  ];
}

/// Response model for chat history
class ChatHistoryResponse extends Equatable implements HasabResponse {
  /// List of chat messages
  final List<ChatMessage> messages;

  /// Conversation ID
  final String conversationId;

  /// Total message count
  final int totalCount;

  const ChatHistoryResponse({
    required this.messages,
    required this.conversationId,
    required this.totalCount,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      messages: (json['messages'] as List<dynamic>)
          .map(
            (msg) =>
                ChatMessage.fromJson(Map<String, dynamic>.from(msg as Map)),
          )
          .toList(),
      conversationId: json['conversation_id']?.toString() ?? '',
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'conversation_id': conversationId,
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [messages, conversationId, totalCount];
}

/// Individual chat message
class ChatMessage extends Equatable {
  /// Message content
  final String content;

  /// Message role (user, assistant, system)
  final String role;

  /// Message ID
  final String messageId;

  /// Timestamp
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.role,
    required this.messageId,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      messageId: json['message_id']?.toString() ?? '',
      timestamp: DateTime.parse(
        json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role,
      'message_id': messageId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [content, role, messageId, timestamp];
}
