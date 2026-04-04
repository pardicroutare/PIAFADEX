import 'package:flutter/material.dart';

void main() {
  runApp(const PiafadexApp());
}

class PiafadexApp extends StatelessWidget {
  const PiafadexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIAFADEX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC43B2B)),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('PIAFADEX — Le Pokédex des oiseaux'),
        ),
      ),
    );
  }
}
