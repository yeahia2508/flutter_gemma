import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gemma_example/chat_widget.dart';
import 'package:flutter_gemma_example/loading_widget.dart';
import 'package:flutter_gemma_example/models/model.dart';
import 'package:flutter_gemma_example/services/llama_service.dart';
import 'package:flutter_gemma_example/services/model_download_service.dart';
import 'package:flutter_gemma_example/model_selection_screen.dart';
import 'package:flutter_gemma_example/chat_message.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.model = Model.gemma3n_e2b_it_q4km});

  final Model model;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late final LlamaService _llamaService;
  StreamSubscription<String>? _responseSubscription;
  final _messages = <ChatMessage>[];
  bool _isModelInitialized = false;
  bool _isStreaming = false;
  String? _error;
  String _appTitle = 'Flutter Llama Example';

  @override
  void initState() {
    super.initState();
    _llamaService = LlamaService(model: widget.model);
    _initializeModel();
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    _llamaService.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      final modelDownloadService = ModelDownloadService(model: widget.model);
      final documentsPath = (await getApplicationDocumentsDirectory()).path;
      final modelPath = '$documentsPath/${widget.model.filename}';

      if (!await modelDownloadService.isModelDownloaded(modelPath)) {
        // For simplicity, we're not showing download progress here.
        // The model_download_screen.dart handles that UI.
        await modelDownloadService.downloadModel(modelPath, onProgress: (p) {
          // We can optionally update a state here to show progress,
          // but for now we do nothing as the download screen handles this.
        });
      }

      await _llamaService.init(modelPath: modelPath);
      
      _responseSubscription = _llamaService.responseStream.listen(
        (token) {
          setState(() {
            if (_messages.isNotEmpty && !_messages.last.isUser) {
              // Append token to the last message if it's from the model
              final lastMessage = _messages.last;
              _messages[_messages.length - 1] =
                  ChatMessage(text: lastMessage.text + token, isUser: false);
            } else {
              // This case shouldn't happen in normal streaming, but as a fallback
              _messages.add(ChatMessage(text: token, isUser: false));
            }
          });
        },
        onDone: () {
          setState(() {
            _isStreaming = false;
          });
        },
        onError: (err) {
          setState(() {
            _error = 'An error occurred: $err';
            _isStreaming = false;
          });
        },
      );
      setState(() {
        _isModelInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize model: $e';
      });
    }
  }

  void _handleSendMessage(String text) {
    setState(() {
      _error = null;
      _isStreaming = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      // Add a placeholder for the model's response
      _messages.add(ChatMessage(text: '', isUser: false));
    });
    _llamaService.sendPrompt(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b2351),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b2351),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ModelSelectionScreen(),
              ),
              (route) => false,
            );
          },
        ),
        title: Text(_appTitle),
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/background.png',
              width: 200,
              height: 200,
            ),
          ),
          _isModelInitialized
              ? Column(
                  children: [
                    if (_error != null) _buildErrorBanner(_error!),
                    Expanded(
                      child: ChatListWidget(
                        messages: _messages,
                        onSendMessage: _handleSendMessage,
                        isProcessing: _isStreaming,
                      ),
                    )
                  ],
                )
              : const LoadingWidget(message: 'Initializing Llama model...'),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String errorMessage) {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
