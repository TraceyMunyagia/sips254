import '../../../data/models/cocktail_model.dart';
import '../../../data/services/supabase_service.dart';

class ProfileRepository {
  final _client = SupabaseService.client;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  Future<int> getFollowerCount(String userId) async {
    final data = await _client.from('follows').select('id').eq('following_id', userId);
    return (data as List).length;
  }

  Future<int> getFollowingCount(String userId) async {
    final data = await _client.from('follows').select('id').eq('follower_id', userId);
    return (data as List).length;
  }

  Future<List<Cocktail>> getCreatedCocktails(String userId) async {
    final data = await _client
        .from('cocktails')
        .select()
        .eq('created_by', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Cocktail.fromMap(e)).toList();
  }

  Future<List<Cocktail>> getSavedCocktails(String userId) async {
    final data = await _client
        .from('saves')
        .select('cocktails(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => Cocktail.fromMap(row['cocktails'] as Map<String, dynamic>))
        .toList();
  }

  Future<List<Cocktail>> getLikedCocktails(String userId) async {
    final data = await _client
        .from('likes')
        .select('cocktails(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => Cocktail.fromMap(row['cocktails'] as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id, type, is_read, created_at, cocktail_id, profiles!notifications_actor_id_fkey(username)')
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> markNotificationsRead(String userId) async {
    await _client.from('notifications').update({'is_read': true}).eq('recipient_id', userId);
  }
}