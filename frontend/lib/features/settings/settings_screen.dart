import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('V1: badges généraux + trouvaille activés. Badges spécialisés en TODO V1.1.'),
      ),
    );
  }
}
