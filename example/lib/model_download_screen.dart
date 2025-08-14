import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma_example/chat_screen.dart';
import 'package:flutter_gemma_example/services/model_download_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/model.dart';

class ModelDownloadScreen extends StatefulWidget {
  final Model model;

  const ModelDownloadScreen({super.key, required this.model});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  late ModelDownloadService _downloadService;
  late String _modelPath;
  bool _needToDownload = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _downloadService = ModelDownloadService(model: widget.model);
    _initialize();
  }

  Future<void> _initialize() async {
    final documentsPath = (await getApplicationDocumentsDirectory()).path;
    _modelPath = '$documentsPath/${widget.model.filename}';
    _needToDownload = !(await _downloadService.isModelDownloaded(_modelPath));
    setState(() {});
  }

  Future<void> _downloadModel() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _downloadService.downloadModel(
        _modelPath,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );
      setState(() {
        _needToDownload = false;
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to download the model.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _progress = 0.0;
        });
      }
    }
  }

  Future<void> _deleteModel() async {
    await _downloadService.deleteModel(_modelPath);
    setState(() {
      _needToDownload = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Download'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download ${widget.model.displayName} Model',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.model.licenseUrl.isNotEmpty)
              RichText(
                text: TextSpan(
                  text: 'License Agreement: ',
                  children: [
                    TextSpan(
                      text: widget.model.licenseUrl,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse(widget.model.licenseUrl));
                        },
                    ),
                  ],
                ),
              ),
            Center(
              child: _progress > 0.0
                  ? Column(
                      children: [
                        Text(
                            'Download Progress: ${(_progress * 100).toStringAsFixed(1)}%'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _progress),
                      ],
                    )
                  : ElevatedButton(
                      onPressed:
                          !needToDownload ? _deleteModel : _downloadModel,
                      child: Text(!needToDownload ? 'Delete' : 'Download'),
                    ),
            ),
            const Spacer(),
            if (!needToDownload)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute<void>(builder: (context) {
                        return ChatScreen(model: widget.model);
                      }));
                    },
                    child: const Text('Use the model in Chat Screen'),
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
