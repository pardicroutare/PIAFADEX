import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _error;

  Future<void> _pickAndCrop(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 92);
      if (picked == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l’oiseau',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
        ],
      );

      if (!mounted) {
        return;
      }

      final finalPath = cropped?.path ?? picked.path;
      Navigator.pushNamed(
        context,
        PiafadexRouter.analysisLoading,
        arguments: AnalysisLoadingArgs(imagePath: finalPath),
      );
    } catch (_) {
      setState(() {
        _error = 'Impossible de récupérer l’image. Vérifie les permissions caméra/galerie.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Prends une photo ou choisis une image, puis recadre l’oiseau.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _pickAndCrop(ImageSource.camera),
              child: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : () => _pickAndCrop(ImageSource.gallery),
              child: const Text('Choisir depuis la galerie'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
