import 'package:flutter/material.dart';
import 'package:flutter_gemma_example/chat_input_field.dart';
import 'package:flutter_gemma_example/chat_message.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({
    required this.messages,
    required this.onSendMessage,
    this.isProcessing = false,
    super.key,
  });

  final List<ChatMessage> messages;
  final ValueChanged<String> onSendMessage;
  final bool isProcessing;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            reverse: true,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages.reversed.toList()[index];
              return ChatMessageWidget(message: message);
            },
          ),
        ),
        if (widget.isProcessing)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ChatInputField(
          handleSubmitted: widget.onSendMessage,
        ),
      ],
    );
  }
}