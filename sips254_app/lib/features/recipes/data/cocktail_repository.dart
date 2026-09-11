import '../../../data/models/cocktail_model.dart';
import '../../../data/services/supabase_service.dart';

class CocktailRepository {
  final _client = SupabaseService.client;

  Future<List<Cocktail>> getPublishedCocktails({int limit = 20}) async {
    final data = await _client
        .from('cocktails')
        .select()
        .eq('status', 'published')
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }

  Future<List<Cocktail>> getKenyanCocktails({int limit = 20}) async {
    final data = await _client
        .from('cocktails')
        .select()
        .eq('is_kenyan_inspired', true)
        .eq('status', 'published')
        .limit(limit);

    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }

  /// Fetches a cocktail plus its resolved ingredient list (names joined
  /// from ingredients/spirits tables rather than raw foreign keys).
  Future<Cocktail?> getCocktailWithIngredients(String id) async {
    final cocktailData =
        await _client.from('cocktails').select().eq('id', id).maybeSingle();
    if (cocktailData == null) return null;

    final ingredientRows = await _client
        .from('cocktail_ingredients')
        .select('amount, unit, is_optional, ingredient_id, spirit_id, '
            'ingredients(name), spirits(name)')
        .eq('cocktail_id', id);

    final ingredients = (ingredientRows as List).map((row) {
      final ingredientJoin = row['ingredients'] as Map<String, dynamic>?;
      final spiritJoin = row['spirits'] as Map<String, dynamic>?;

      return CocktailIngredientEntry(
        ingredientId: row['ingredient_id'] as String?,
        spiritId: row['spirit_id'] as String?,
        name: ingredientJoin?['name'] as String? ??
            spiritJoin?['name'] as String? ??
            'Unknown',
        amount: row['amount'] as num,
        unit: row['unit'] as String,
        isOptional: row['is_optional'] as bool? ?? false,
      );
    }).toList();

    final cocktail = Cocktail.fromMap(cocktailData);
    return Cocktail(
      id: cocktail.id,
      name: cocktail.name,
      description: cocktail.description,
      strength: cocktail.strength,
      sweetness: cocktail.sweetness,
      sourness: cocktail.sourness,
      bitterness: cocktail.bitterness,
      fruitiness: cocktail.fruitiness,
      fizz: cocktail.fizz,
      difficulty: cocktail.difficulty,
      servings: cocktail.servings,
      garnish: cocktail.garnish,
      instructions: cocktail.instructions,
      isKenyanInspired: cocktail.isKenyanInspired,
      photoUrl: cocktail.photoUrl,
      ingredients: ingredients,
    );
  }

  Future<List<Map<String, dynamic>>> getEquipmentAlternatives() async {
    final data = await _client.from('equipment_alternatives').select();
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<String> createCocktail({
    required String name,
    required String? description,
    required String instructions,
    required int strength,
    required int sweetness,
    required int sourness,
    required int bitterness,
    required int fruitiness,
    required int fizz,
    required int difficulty,
    required int servings,
    required String? garnish,
    required bool isKenyanInspired,
    required String createdBy,
    String? photoUrl,
  }) async {
    final result = await _client.from('cocktails').insert({
      'name': name,
      'description': description,
      'instructions': instructions,
      'strength': strength,
      'sweetness': sweetness,
      'sourness': sourness,
      'bitterness': bitterness,
      'fruitiness': fruitiness,
      'fizz': fizz,
      'difficulty': difficulty,
      'servings': servings,
      'garnish': garnish,
      'is_kenyan_inspired': isKenyanInspired,
      'is_community_recipe': true,
      'status': 'published',
      'created_by': createdBy,
      'photo_url': photoUrl,
    }).select().single();

    return result['id'] as String;
  }

  Future<void> addCocktailIngredient({
    required String cocktailId,
    String? ingredientId,
    String? spiritId,
    required num amount,
    required String unit,
  }) async {
    await _client.from('cocktail_ingredients').insert({
      'cocktail_id': cocktailId,
      'ingredient_id': ingredientId,
      'spirit_id': spiritId,
      'amount': amount,
      'unit': unit,
    });
  }
}