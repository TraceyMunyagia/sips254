class CocktailIngredientEntry {
  final String? ingredientId;
  final String? spiritId;
  final String name;      // resolved display name, joined from ingredients/spirits
  final num amount;
  final String unit;
  final bool isOptional;

  CocktailIngredientEntry({
    this.ingredientId,
    this.spiritId,
    required this.name,
    required this.amount,
    required this.unit,
    required this.isOptional,
  });
}

class Cocktail {
  final String id;
  final String name;
  final String? description;
  final int strength;
  final int sweetness;
  final int sourness;
  final int bitterness;
  final int fruitiness;
  final int fizz;
  final int difficulty;
  final int servings;
  final String? garnish;
  final String instructions;
  final bool isKenyanInspired;
  final String? photoUrl;
  final List<CocktailIngredientEntry> ingredients;

  Cocktail({
    required this.id,
    required this.name,
    this.description,
    required this.strength,
    required this.sweetness,
    required this.sourness,
    required this.bitterness,
    required this.fruitiness,
    required this.fizz,
    required this.difficulty,
    required this.servings,
    this.garnish,
    required this.instructions,
    required this.isKenyanInspired,
    this.photoUrl,
    this.ingredients = const [],
  });

  factory Cocktail.fromMap(Map<String, dynamic> map) => Cocktail(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        strength: map['strength'] as int? ?? 0,
        sweetness: map['sweetness'] as int? ?? 0,
        sourness: map['sourness'] as int? ?? 0,
        bitterness: map['bitterness'] as int? ?? 0,
        fruitiness: map['fruitiness'] as int? ?? 0,
        fizz: map['fizz'] as int? ?? 0,
        difficulty: map['difficulty'] as int? ?? 0,
        servings: map['servings'] as int? ?? 1,
        garnish: map['garnish'] as String?,
        instructions: map['instructions'] as String,
        isKenyanInspired: map['is_kenyan_inspired'] as bool? ?? false,
        photoUrl: map['photo_url'] as String?,
      );
}