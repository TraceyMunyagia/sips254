import '../../../data/models/cocktail_model.dart';
import '../../../data/services/supabase_service.dart';

class SearchRepository {
  final _client = SupabaseService.client;

  Future<List<Cocktail>> searchCocktails(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client
        .from('cocktails')
        .select()
        .textSearch('search_vector', query.trim(), config: 'english')
        .eq('status', 'published')
        .limit(30);
    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client
        .from('ingredients')
        .select()
        .textSearch('search_vector', query.trim(), config: 'english')
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchCreators(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client
        .from('profiles')
        .select()
        .textSearch('search_vector', query.trim(), config: 'english')
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Cocktail>> getTrending({int limit = 20}) async {
    final data = await _client.from('trending_cocktails').select().limit(limit);
    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }

  Future<List<Cocktail>> getByCategory(String categoryName, {int limit = 30}) async {
    final data = await _client
        .from('cocktails')
        .select('*, categories!inner(name)')
        .eq('categories.name', categoryName)
        .eq('status', 'published')
        .limit(limit);
    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }
}