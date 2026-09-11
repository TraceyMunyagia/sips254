import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/social_repository.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepository());

final likeCountProvider = FutureProvider.family<int, String>((ref, cocktailId) {
  return ref.watch(socialRepositoryProvider).getLikeCount(cocktailId);
});

final isLikedProvider =
    FutureProvider.family<bool, ({String cocktailId, String userId})>((ref, params) {
  return ref.watch(socialRepositoryProvider).isLiked(params.cocktailId, params.userId);
});

final isSavedProvider =
    FutureProvider.family<bool, ({String cocktailId, String userId})>((ref, params) {
  return ref.watch(socialRepositoryProvider).isSaved(params.cocktailId, params.userId);
});

final commentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, cocktailId) {
  return ref.watch(socialRepositoryProvider).getComments(cocktailId);
});