import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> handleSubmitted;

  const ChatInputField({
    super.key,
    required this.handleSubmitted,
  });

  @override
  ChatInputFieldState createState() => ChatInputFieldState();
}

class ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.handleSubmitted(text.trim());
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).hoverColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1a3a5c),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Send message',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                maxLines: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white70),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}
