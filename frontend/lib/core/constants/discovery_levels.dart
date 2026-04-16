import 'package:flutter/material.dart';

class DiscoveryLevelMeta {
  const DiscoveryLevelMeta({required this.level, required this.label, required this.color});

  final int level;
  final String label;
  final Color color;
}

const discoveryLevels = <DiscoveryLevelMeta>[
  DiscoveryLevelMeta(level: 1, label: 'Commun', color: Color(0xFF4CAF50)),
  DiscoveryLevelMeta(level: 2, label: 'Pas banal', color: Color(0xFF42A5F5)),
  DiscoveryLevelMeta(level: 3, label: 'Curieux', color: Color(0xFF26A69A)),
  DiscoveryLevelMeta(level: 4, label: 'Sacrée trouvaille !', color: Color(0xFF8E44AD)),
  DiscoveryLevelMeta(level: 5, label: 'Fabuleux !', color: Color(0xFFFB8C00)),
  DiscoveryLevelMeta(level: 6, label: 'Inouï, c’est rarissime !', color: Color(0xFFD32F2F)),
];
