import 'package:flutter/material.dart';
import 'package:flutter_gemma_example/model_download_screen.dart';
import 'package:flutter_gemma_example/models/model.dart';

class ModelSelectionScreen extends StatelessWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Since we only have one model now, we don't need to filter.
    // We just display the one model available.
    final model = Model.values.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0b2351),
      appBar: AppBar(
        title: const Text('Select a Model'),
        backgroundColor: const Color(0xFF0b2351),
      ),
      body: Center(
        child: ListTile(
          title: Text(model.displayName),
          subtitle: Text('GGUF Format - using llama_cpp_dart'),
          leading: const Icon(Icons.model_training),
          onTap: () {
            // The download screen should handle both web and mobile.
            // On web, it might just navigate directly to the chat screen
            // if we assume the model is served from a URL that doesn't require
            // a separate download step. For now, we go to the download screen.
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => ModelDownloadScreen(
                  model: model,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
