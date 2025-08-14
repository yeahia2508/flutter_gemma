import 'dart:async';
import 'dart:io';

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

    // Create the correct PromptFormat instance based on the enum type.
    PromptFormat format;
    switch (model.formatType) {
      case PromptFormatType.gemini:
        format = const GeminiFormat();
        break;
      // Add other cases here if more formats are supported in the future
      default:
        // Default to Gemini or throw an error
        format = const GeminiFormat();
    }

    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: ModelParams(
          // Using default model parameters for now
          ),
      contextParams: ContextParams()
        ..nCtx = 2048, // Set context size using cascade operator
      samplingParams: SamplerParams(),
      format: format,
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
