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