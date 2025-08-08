import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A simple data class for holding chat message data.
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

/// A widget that displays a single chat message with styling similar to the original.
class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                // Using original colors
                color: const Color(0xFF1a4a7c),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: message.text.isNotEmpty
                  ? MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        code: const TextStyle(
                          backgroundColor: Color(0xFF2a5a8c),
                          color: Colors.white,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFF2a5a8c),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return isUser
        ? const CircleAvatar(
            backgroundColor: Color(0xFF1a4a7c),
            child: Icon(Icons.person, color: Colors.white),
          )
        : CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundImage: AssetImage('assets/gemma.png'),
          );
  }
}