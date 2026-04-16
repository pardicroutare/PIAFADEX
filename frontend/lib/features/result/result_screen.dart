import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../app/router.dart';
import '../../core/constants/network.dart';
import '../../data/api/piafadex_api_client.dart';
import '../../data/models/analyze_bird_response.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.args});

  final ResultArgs args;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isGeneratingAudio = false;
  String? _audioError;

  AnalyzeBirdResponse get _response => AnalyzeBirdResponse.fromJson(widget.args.payload);

  Future<void> _generateAndPlayAudio() async {
    final bird = _response.bird;
    if (bird == null) {
      return;
    }
    setState(() {
      _isGeneratingAudio = true;
      _audioError = null;
    });

    try {
      final api = PiafadexApiClient(baseUrl: defaultApiBaseUrl);
      final bytes = await api.generateAudio(
        commonName: bird.commonName,
        scientificName: bird.scientificName,
        funTypeLabel: bird.funTypeLabel,
        habitatShort: bird.habitatShort,
        dietShort: bird.dietShort,
        professorCommentaryText: bird.professorCommentaryText,
      );
      await _player.play(BytesSource(bytes));
    } catch (_) {
      setState(() {
        _audioError = 'Impossible de générer/lecture audio. Vérifie le backend.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAudio = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _response;
    final bird = result.bird;
    final issue = result.issue;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: bird != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bird.commonName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          Text(bird.scientificName),
                          const SizedBox(height: 8),
                          Text('Confiance: ${bird.confidenceLabel}'),
                          Text('Niveau de trouvaille: ${bird.discoveryLevel}'),
                          const SizedBox(height: 8),
                          Text('Type: ${bird.funTypeLabel}'),
                          Text('Habitat: ${bird.habitatShort}'),
                          Text('Régime: ${bird.dietShort}'),
                          const SizedBox(height: 8),
                          Text(bird.professorCommentaryText),
                          const SizedBox(height: 12),
                          const Text('Alternatives:', style: TextStyle(fontWeight: FontWeight.w600)),
                          ...bird.alternatives.map(
                            (alt) => Text('• ${alt.commonName} (${alt.scientificName})'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Image inexploitable', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('Code: ${issue?.code ?? 'inconnu'}'),
                          Text(issue?.userReason ?? ''),
                          const SizedBox(height: 8),
                          Text(issue?.professorCommentaryText ?? ''),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (bird == null || _isGeneratingAudio) ? null : _generateAndPlayAudio,
              child: Text(_isGeneratingAudio ? 'Génération audio...' : 'Valider et générer audio'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Corriger parmi alternatives'),
            ),
            if (_audioError != null) ...[
              const SizedBox(height: 10),
              Text(_audioError!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
