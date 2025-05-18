class InscriptionTrait {
  final String name;
  final String value;
  final double rarity;

  InscriptionTrait({
    required this.name,
    required this.value,
    required this.rarity,
  });

  factory InscriptionTrait.fromMap(Map<String, dynamic> map) {
    return InscriptionTrait(
      name: map['name'],
      value: map['value'],
      rarity: (map['rarity'] as num).toDouble(),
    );
  }
}
