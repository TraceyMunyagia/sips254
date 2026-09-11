import '../../../data/services/supabase_service.dart';

class SocialRepository {
  final _client = SupabaseService.client;

  Future<bool> isLiked(String cocktailId, String userId) async {
    final data = await _client
        .from('likes')
        .select('id')
        .eq('cocktail_id', cocktailId)
        .eq('user_id', userId);
    return (data as List).isNotEmpty;
  }

  Future<int> getLikeCount(String cocktailId) async {
    final data = await _client.from('likes').select('id').eq('cocktail_id', cocktailId);
    return (data as List).length;
  }

  Future<void> toggleLike(String cocktailId, String userId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await _client.from('likes').delete().eq('cocktail_id', cocktailId).eq('user_id', userId);
    } else {
      await _client.from('likes').insert({'cocktail_id': cocktailId, 'user_id': userId});
    }
  }

  Future<bool> isSaved(String cocktailId, String userId) async {
    final data = await _client
        .from('saves')
        .select('id')
        .eq('cocktail_id', cocktailId)
        .eq('user_id', userId);
    return (data as List).isNotEmpty;
  }

  Future<void> toggleSave(String cocktailId, String userId, bool currentlySaved) async {
    if (currentlySaved) {
      await _client.from('saves').delete().eq('cocktail_id', cocktailId).eq('user_id', userId);
    } else {
      await _client.from('saves').insert({'cocktail_id': cocktailId, 'user_id': userId});
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String cocktailId) async {
    final data = await _client
        .from('comments')
        .select('id, content, created_at, user_id, profiles(username, avatar_url)')
        .eq('cocktail_id', cocktailId)
        .order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> addComment(String cocktailId, String userId, String content) async {
    await _client.from('comments').insert({
      'cocktail_id': cocktailId,
      'user_id': userId,
      'content': content,
    });
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    final data = await _client
        .from('follows')
        .select('id')
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
    return (data as List).isNotEmpty;
  }

  Future<void> toggleFollow(String followerId, String followingId, bool currentlyFollowing) async {
    if (currentlyFollowing) {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } else {
      await _client.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
    }
  }
}