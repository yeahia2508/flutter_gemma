import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma_example/models/model.dart';

class ModelDownloadService {
  final Model model;

  ModelDownloadService({required this.model});

  /// Checks if the model file exists on disk.
  Future<bool> isModelDownloaded(String modelPath) async {
    final file = File(modelPath);
    return file.existsSync();
  }

  /// Downloads the model file and tracks progress.
  Future<void> downloadModel(
    String modelPath, {
    required Function(double) onProgress,
  }) async {
    http.StreamedResponse? response;
    IOSink? fileSink;

    try {
      final file = File(modelPath);

      final request = http.Request('GET', Uri.parse(model.url));
      response = await request.send();

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        fileSink = file.openWrite(); // Overwrite existing file

        int received = 0;
        await for (final chunk in response.stream) {
          fileSink.add(chunk);
          received += chunk.length;
          onProgress(contentLength > 0 ? received / contentLength : 0.0);
        }
      } else {
        throw Exception('Failed to download the model. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model: $e');
      }
      rethrow;
    } finally {
      await fileSink?.close();
    }
  }

  /// Deletes the downloaded file.
  Future<void> deleteModel(String modelPath) async {
    try {
      final file = File(modelPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting model: $e');
      }
    }
  }
}
