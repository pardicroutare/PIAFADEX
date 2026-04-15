class BadgeSeed {
  const BadgeSeed({
    required this.code,
    required this.name,
    required this.description,
    required this.tier,
    this.isHidden = false,
  });

  final String code;
  final String name;
  final String description;
  final String tier;
  final bool isHidden;
}

const generalAndFindBadges = <BadgeSeed>[
  BadgeSeed(code: 'first_bird', name: 'Premier Piaf', description: 'Découvrir 1 oiseau', tier: 'bronze'),
  BadgeSeed(code: 'five_birds', name: 'Petit Inventaire', description: 'Découvrir 5 oiseaux', tier: 'bronze'),
  BadgeSeed(code: 'ten_birds', name: 'Registre Bien Tenu', description: 'Découvrir 10 oiseaux', tier: 'argent'),
  BadgeSeed(code: 'twenty_five_birds', name: 'Grand Catalogueur', description: 'Découvrir 25 oiseaux', tier: 'or'),
  BadgeSeed(code: 'fifty_birds', name: 'Archiviste à Plumes', description: 'Découvrir 50 oiseaux', tier: 'platine'),
  BadgeSeed(code: 'one_high_find', name: 'Curieux du Rare', description: '1 découverte de niveau 4+', tier: 'bronze'),
  BadgeSeed(code: 'five_high_find', name: 'Flair Distingué', description: '5 découvertes de niveau 4+', tier: 'argent'),
  BadgeSeed(code: 'ten_high_find', name: 'Œil d’Exception', description: '10 découvertes de niveau 4+', tier: 'or'),
  BadgeSeed(code: 'twenty_high_find', name: 'Cabinet des Merveilles', description: '20 découvertes de niveau 4+', tier: 'platine'),
  BadgeSeed(code: 'five_favorites', name: 'Collectionneur Soigneux', description: 'Marquer 5 favoris', tier: 'bronze'),
  BadgeSeed(code: 'five_audio', name: 'Élève Studieux', description: 'Écouter 5 commentaires', tier: 'bronze'),
  BadgeSeed(code: 'open_pokedex_ten', name: 'Conservateur du Pokédex', description: 'Ouvrir le Pokédex 10 fois', tier: 'bronze'),
  BadgeSeed(code: 'unlock_five_badges', name: 'Amateur de Badges', description: 'Débloquer 5 badges', tier: 'argent'),
  BadgeSeed(code: 'equip_first_sticker', name: 'Esthète du Registre', description: 'Équiper 1 sticker', tier: 'bronze'),
  BadgeSeed(code: 'save_twenty', name: 'Fidèle du Bestiaire', description: 'Sauvegarder 20 découvertes', tier: 'or'),
  BadgeSeed(code: 'mystery_hidden_01', name: 'Badge caché V1', description: 'Mystère', tier: 'hidden', isHidden: true),
];
