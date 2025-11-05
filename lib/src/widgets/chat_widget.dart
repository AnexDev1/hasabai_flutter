import 'package:flutter/material.dart';
import 'package:hasab_ai_flutter/src/services/chat.dart';
import 'package:hasab_ai_flutter/src/models/response_models.dart';

/// A prebuilt chat widget for Hasab AI conversations
class ChatWidget extends StatefulWidget {
  /// The chat service
  final ChatService chatService;

  /// Optional conversation ID to continue an existing conversation
  final String? conversationId;

  /// Optional system prompt
  final String? systemPrompt;

  /// Callback when a new message is sent
  final void Function(String message)? onMessageSent;

  /// Callback when a response is received
  final void Function(ChatResponse response)? onResponseReceived;

  /// Callback when an error occurs
  final void Function(String error)? onError;

  /// Placeholder text for the input field
  final String? inputPlaceholder;

  /// Show timestamps on messages
  final bool showTimestamps;

  /// Custom message bubble builder
  final Widget Function(ChatMessage message, bool isUser)? messageBubbleBuilder;

  const ChatWidget({
    super.key,
    required this.chatService,
    this.conversationId,
    this.systemPrompt,
    this.onMessageSent,
    this.onResponseReceived,
    this.onError,
    this.inputPlaceholder,
    this.showTimestamps = false,
    this.messageBubbleBuilder,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_currentConversationId == null) return;

    try {
      final history = await widget.chatService.getHistory(
        conversationId: _currentConversationId,
      );

      setState(() {
        _messages.clear();
        // Find the conversation with the matching ID and get its messages
        final conversation = history.history
            .where((conv) => conv.id.toString() == _currentConversationId)
            .firstOrNull;
        if (conversation != null) {
          _messages.addAll(conversation.messages);
        }
      });

      _scrollToBottom();
    } catch (e) {
      widget.onError?.call('Failed to load chat history: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      // Add user message to UI immediately
      _messages.add(
        ChatMessage(
          content: message,
          role: 'user',
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
    widget.onMessageSent?.call(message);

    try {
      final response = await widget.chatService.sendMessage(
        message,
        conversationId: _currentConversationId,
        systemPrompt: widget.systemPrompt,
      );

      setState(() {
        _currentConversationId = response.conversationId;
        // Add AI response to UI
        _messages.add(
          ChatMessage(
            content: response.message,
            role: 'assistant',
            messageId: response.messageId,
            timestamp: response.timestamp,
          ),
        );
      });

      _scrollToBottom();
      widget.onResponseReceived?.call(response);
    } catch (e) {
      widget.onError?.call('Failed to send message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'Start a conversation',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.role == 'user';

                    if (widget.messageBubbleBuilder != null) {
                      return widget.messageBubbleBuilder!(message, isUser);
                    }

                    return _buildMessageBubble(message, isUser);
                  },
                ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.showTimestamps) ...[
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
              decoration: InputDecoration(
                hintText: widget.inputPlaceholder ?? 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
