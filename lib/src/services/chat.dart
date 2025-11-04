import 'package:hasab_ai_flutter/src/hasab_api_client.dart';
import 'package:hasab_ai_flutter/src/models/request_models.dart';
import 'package:hasab_ai_flutter/src/models/response_models.dart';
import 'package:hasab_ai_flutter/src/models/hasab_exception.dart';

/// Service for AI chat interactions
class ChatService {
  final HasabApiClient _client;

  /// Create a new Chat service
  ChatService(this._client);

  /// Send a message to Hasab AI and get a response
  ///
  /// [message] The message to send
  /// [conversationId] Optional conversation ID to continue a conversation
  /// [systemPrompt] Optional system prompt for context
  /// [options] Additional options
  ///
  /// Returns a [ChatResponse] with the AI's response
  ///
  /// Throws [HasabException] if the request fails
  /// Throws [HasabValidationException] if parameters are invalid
  Future<ChatResponse> sendMessage(
    String message, {
    String? conversationId,
    String? systemPrompt,
    Map<String, dynamic>? options,
  }) async {
    // Validate message
    if (message.trim().isEmpty) {
      throw HasabValidationException(message: 'Message cannot be empty');
    }

    // Create request
    final request = ChatRequest(
      message: message,
      conversationId: conversationId,
      systemPrompt: systemPrompt,
      options: options,
    );

    try {
      final response = await _client.post('/chat', data: request.toJson());

      return ChatResponse.fromJson(response);
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to send chat message',
        details: e.toString(),
      );
    }
  }

  /// Get chat history for a conversation
  ///
  /// [conversationId] Optional conversation ID (returns all if not provided)
  /// [limit] Maximum number of messages to retrieve
  /// [offset] Offset for pagination
  ///
  /// Returns a [ChatHistoryResponse] with the chat history
  Future<ChatHistoryResponse> getHistory({
    String? conversationId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (conversationId != null)
        queryParams['conversation_id'] = conversationId;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _client.get(
        '/chat/history',
        queryParameters: queryParams,
      );

      return ChatHistoryResponse.fromJson(response);
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to get chat history',
        details: e.toString(),
      );
    }
  }

  /// Stream chat responses for real-time interaction
  ///
  /// [message] The message to send
  /// [conversationId] Optional conversation ID
  /// [systemPrompt] Optional system prompt
  ///
  /// Returns a stream of partial responses
  ///
  /// Note: This requires streaming support from the API
  Stream<String> sendMessageStream(
    String message, {
    String? conversationId,
    String? systemPrompt,
  }) async* {
    // This is a placeholder for streaming chat
    // Actual implementation depends on API support for streaming

    // For now, we'll just return the full response
    final response = await sendMessage(
      message,
      conversationId: conversationId,
      systemPrompt: systemPrompt,
    );

    yield response.message;
  }

  /// Delete a conversation and its history
  ///
  /// [conversationId] The conversation ID to delete
  ///
  /// Returns true if successful
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _client.delete('/chat/conversation/$conversationId');
      return true;
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to delete conversation',
        details: e.toString(),
      );
    }
  }

  /// Clear all chat history
  ///
  /// Returns true if successful
  Future<bool> clearAllHistory() async {
    try {
      await _client.delete('/chat/history');
      return true;
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to clear chat history',
        details: e.toString(),
      );
    }
  }

  /// Get list of all conversations
  ///
  /// [limit] Maximum number of conversations to retrieve
  /// [offset] Offset for pagination
  ///
  /// Returns a list of conversation IDs with metadata
  Future<List<Map<String, dynamic>>> getConversations({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _client.get(
        '/chat/conversations',
        queryParameters: queryParams,
      );

      final conversations = response['conversations'] as List<dynamic>;
      return conversations.map((c) => c as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to get conversations',
        details: e.toString(),
      );
    }
  }

  /// Start a new conversation
  ///
  /// [initialMessage] Optional first message
  /// [systemPrompt] Optional system prompt
  ///
  /// Returns the conversation ID
  Future<String> startConversation({
    String? initialMessage,
    String? systemPrompt,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (initialMessage != null) data['message'] = initialMessage;
      if (systemPrompt != null) data['system_prompt'] = systemPrompt;

      final response = await _client.post('/chat/conversation', data: data);

      return response['conversation_id'] as String;
    } catch (e) {
      if (e is HasabException) {
        rethrow;
      }
      throw HasabException(
        message: 'Failed to start conversation',
        details: e.toString(),
      );
    }
  }
}
