import 'dart:async';

import 'package:flutter/material.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:flutter_gemma_example/models/model.dart' as app;

class LlamaService {
  LlamaParent? _llamaParent;
  final app.Model model;

  final StreamController<String> _responseController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _responseController.stream;

  LlamaService({required this.model});

  Future<void> init({required String modelPath}) async {
    // Set the library path according to the platform.
    // This is a crucial step and requires the user to have compiled
    // the llama.cpp library and placed it in the correct location.
    // TODO: The user must replace these paths with the actual paths to their
    // compiled libraries.
    // if (Platform.isMacOS || Platform.isLinux) {
    //   Llama.libraryPath = 'path/to/libllama.so';
    // } else if (Platform.isWindows) {
    //   Llama.libraryPath = 'path/to/llama.dll';
    // }

    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: ModelParams(
        nCtx: 2048, // Context size
      ),
      contextParams: ContextParams(),
      samplingParams: SamplerParams(),
      format: model.chatFormat,
    );

    _llamaParent = LlamaParent(loadCommand);

    // Listen to the stream from the isolate and pipe it to our own controller.
    _llamaParent!.stream.listen((response) {
      // The response from the isolate is the generated token.
      _responseController.add(response);
    });

    // Initialize the isolate.
    await _llamaParent!.init();
  }

  void sendPrompt(String prompt) {
    if (_llamaParent == null) {
      throw Exception('LlamaService not initialized. Call init() first.');
    }
    _llamaParent!.sendPrompt(prompt);
  }

  void dispose() {
    _llamaParent?.dispose();
    _responseController.close();
  }
}
