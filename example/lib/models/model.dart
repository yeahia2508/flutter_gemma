import 'package:llama_cpp_dart/llama_cpp_dart.dart';

enum Model {
  gemma3n_e2b_it_q4km(
    displayName: 'Gemma 3 Nano E2B IT (Q4_K_M GGUF)',
    url:
        'https://huggingface.co/unsloth/gemma-3n-E2B-it-GGUF/resolve/main/gemma-3n-E2B-it-Q4_K_M.gguf?download=true',
    filename: 'gemma-3n-E2B-it-Q4_K_M.gguf',
    licenseUrl: 'https://huggingface.co/unsloth/gemma-3n-E2B-it-GGUF',
    chatFormat: GemmaChatFormat(),
  );

  // Define fields for the enum
  final String displayName;
  final String url;
  final String filename;
  final String licenseUrl;
  final ChatFormat chatFormat;

  // Constructor for the enum
  const Model({
    required this.displayName,
    required this.url,
    required this.filename,
    required this.licenseUrl,
    required this.chatFormat,
  });
}