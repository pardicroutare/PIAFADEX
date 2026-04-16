import 'package:flutter/material.dart';
import 'dart:io';

import '../../app/router.dart';
import '../../core/constants/network.dart';
import '../../data/api/piafadex_api_client.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  const AnalysisLoadingScreen({super.key, required this.args});

  final AnalysisLoadingArgs args;

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final api = PiafadexApiClient(baseUrl: defaultApiBaseUrl);
      final result = await api.analyzeBird(
        imageFile: File(widget.args.imagePath),
        clientContext: const {
          'app_version': '1.0.0',
          'locale': 'fr-FR',
        },
      );

      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        PiafadexRouter.result,
        arguments: ResultArgs(
          imagePath: widget.args.imagePath,
          payload: {
            'success': result.success,
            'result_type': result.resultType,
            'bird': result.bird == null
                ? null
                : {
                    'common_name': result.bird!.commonName,
                    'scientific_name': result.bird!.scientificName,
                    'confidence_label': result.bird!.confidenceLabel,
                    'discovery_level': result.bird!.discoveryLevel,
                    'fun_type_label': result.bird!.funTypeLabel,
                    'habitat_short': result.bird!.habitatShort,
                    'diet_short': result.bird!.dietShort,
                    'professor_commentary_text': result.bird!.professorCommentaryText,
                    'alternatives': result.bird!.alternatives
                        .map(
                          (alt) => {
                            'common_name': alt.commonName,
                            'scientific_name': alt.scientificName,
                          },
                        )
                        .toList(),
                  },
            'issue': result.issue == null
                ? null
                : {
                    'code': result.issue!.code,
                    'user_reason': result.issue!.userReason,
                    'professor_commentary_text': result.issue!.professorCommentaryText,
                  },
          },
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Impossible de contacter le backend. Vérifie PIAFADEX_API_BASE_URL et ta connexion réseau.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _errorMessage == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Analyse en cours...'),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 34),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _runAnalysis,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
