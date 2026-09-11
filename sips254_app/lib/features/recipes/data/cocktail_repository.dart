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

  Future<Cocktail?> getCocktailById(String id) async {
    final data = await _client.from('cocktails').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Cocktail.fromMap(data);
  }
}