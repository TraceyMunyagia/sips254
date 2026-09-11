import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cocktail_model.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

final profileDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

final followerCountProvider = FutureProvider.family<int, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getFollowerCount(userId);
});

final followingCountProvider = FutureProvider.family<int, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getFollowingCount(userId);
});

final createdCocktailsProvider = FutureProvider.family<List<Cocktail>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getCreatedCocktails(userId);
});

final savedCocktailsProvider = FutureProvider.family<List<Cocktail>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getSavedCocktails(userId);
});

final likedCocktailsProvider = FutureProvider.family<List<Cocktail>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getLikedCocktails(userId);
});

final notificationsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getNotifications(userId);
});