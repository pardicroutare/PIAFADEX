import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const PiafadexApp());
}

class PiafadexApp extends StatelessWidget {
  const PiafadexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIAFADEX',
      theme: PiafadexTheme.build(),
      initialRoute: PiafadexRouter.home,
      onGenerateRoute: PiafadexRouter.onGenerateRoute,
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
