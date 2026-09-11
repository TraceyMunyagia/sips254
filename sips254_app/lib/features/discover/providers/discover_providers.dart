import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/cocktail_model.dart';
import '../data/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepository());

final searchQueryProvider = StateProvider<String>((ref) => '');

final cocktailSearchResultsProvider = FutureProvider<List<Cocktail>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(searchRepositoryProvider).searchCocktails(query);
});

final trendingCocktailsProvider = FutureProvider<List<Cocktail>>((ref) {
  return ref.watch(searchRepositoryProvider).getTrending();
});

final categoryProvider = FutureProvider.family<List<Cocktail>, String>((ref, category) {
  return ref.watch(searchRepositoryProvider).getByCategory(category);
});