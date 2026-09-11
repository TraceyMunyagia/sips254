class Ingredient {
  final String id;
  final String name;
  final String? type;
  final bool isKenyan;

  Ingredient({
    required this.id,
    required this.name,
    this.type,
    required this.isKenyan,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String?,
        isKenyan: map['is_kenyan'] as bool? ?? false,
      );
}