import 'package:flutter/material.dart';

import '../../app/router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PIAFADEX')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Le Pokédex des oiseaux', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('Flux V1 prioritaire: Capture → Analyse → Résultat → Audio → Sauvegarde locale.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, PiafadexRouter.capture),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Démarrer une capture'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Ouvrir le Pokédex (TODO)'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, PiafadexRouter.settings),
              child: const Text('Paramètres'),
            ),
          ],
        ),
      ),
    );
  }
}
