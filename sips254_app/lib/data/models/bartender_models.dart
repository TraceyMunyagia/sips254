class SuggestedCocktail {
  final String? cocktailId;
  final String name;
  final double matchScore;
  final List<String> haveIngredients;
  final List<String> missingIngredients;
  final String explanation;

  SuggestedCocktail({
    this.cocktailId,
    required this.name,
    required this.matchScore,
    required this.haveIngredients,
    required this.missingIngredients,
    required this.explanation,
  });

  factory SuggestedCocktail.fromMap(Map<String, dynamic> map) => SuggestedCocktail(
        cocktailId: map['cocktail_id'] as String?,
        name: map['name'] as String,
        matchScore: (map['match_score'] as num).toDouble(),
        haveIngredients: List<String>.from(map['have_ingredients'] ?? []),
        missingIngredients: List<String>.from(map['missing_ingredients'] ?? []),
        explanation: map['explanation'] as String? ?? '',
      );
}

class BartenderResult {
  final List<SuggestedCocktail> suggestions;
  final List<String> shoppingSuggestions;

  BartenderResult({required this.suggestions, required this.shoppingSuggestions});

  factory BartenderResult.fromMap(Map<String, dynamic> map) => BartenderResult(
        suggestions: (map['suggestions'] as List)
            .map((e) => SuggestedCocktail.fromMap(e as Map<String, dynamic>))
            .toList(),
        shoppingSuggestions: List<String>.from(map['shopping_suggestions'] ?? []),
      );
}

class ScaledIngredient {
  final String name;
  final double originalAmount;
  final double scaledAmount;
  final String unit;

  ScaledIngredient({
    required this.name,
    required this.originalAmount,
    required this.scaledAmount,
    required this.unit,
  });

  factory ScaledIngredient.fromMap(Map<String, dynamic> map) => ScaledIngredient(
        name: map['name'] as String,
        originalAmount: (map['original_amount'] as num).toDouble(),
        scaledAmount: (map['scaled_amount'] as num).toDouble(),
        unit: map['unit'] as String,
      );
}

class ScaledRecipe {
  final String cocktailName;
  final int targetPeople;
  final int baseServings;
  final double multiplier;
  final List<ScaledIngredient> scaledIngredients;
  final String instructions;
  final String? garnish;

  ScaledRecipe({
    required this.cocktailName,
    required this.targetPeople,
    required this.baseServings,
    required this.multiplier,
    required this.scaledIngredients,
    required this.instructions,
    this.garnish,
  });

  factory ScaledRecipe.fromMap(Map<String, dynamic> map) => ScaledRecipe(
        cocktailName: map['cocktail_name'] as String,
        targetPeople: map['target_people'] as int,
        baseServings: map['base_servings'] as int,
        multiplier: (map['multiplier'] as num).toDouble(),
        scaledIngredients: (map['scaled_ingredients'] as List)
            .map((e) => ScaledIngredient.fromMap(e as Map<String, dynamic>))
            .toList(),
        instructions: map['instructions'] as String,
        garnish: map['garnish'] as String?,
      );
}

class PunchRecommendation {
  final String cocktailId;
  final String name;
  final double matchScore;
  final String explanation;
  final ScaledRecipe scaledRecipe;

  PunchRecommendation({
    required this.cocktailId,
    required this.name,
    required this.matchScore,
    required this.explanation,
    required this.scaledRecipe,
  });

  factory PunchRecommendation.fromMap(Map<String, dynamic> map) => PunchRecommendation(
        cocktailId: map['cocktail_id'] as String,
        name: map['name'] as String,
        matchScore: (map['match_score'] as num).toDouble(),
        explanation: map['explanation'] as String,
        scaledRecipe: ScaledRecipe.fromMap(map['scaled_recipe'] as Map<String, dynamic>),
      );
}

class PunchResult {
  final List<PunchRecommendation> recommendations;

  PunchResult({required this.recommendations});

  factory PunchResult.fromMap(Map<String, dynamic> map) => PunchResult(
        recommendations: (map['recommendations'] as List)
            .map((e) => PunchRecommendation.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}