import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cocktail_model.dart';
import '../../../data/services/storage_service.dart';
import '../data/cocktail_repository.dart';

final cocktailRepositoryProvider = Provider<CocktailRepository>((ref) => CocktailRepository());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final publishedCocktailsProvider = FutureProvider<List<Cocktail>>((ref) {
  return ref.watch(cocktailRepositoryProvider).getPublishedCocktails();
});

final kenyanCocktailsProvider = FutureProvider<List<Cocktail>>((ref) {
  return ref.watch(cocktailRepositoryProvider).getKenyanCocktails();
});

final cocktailDetailProvider =
    FutureProvider.family<Cocktail?, String>((ref, cocktailId) {
  return ref.watch(cocktailRepositoryProvider).getCocktailWithIngredients(cocktailId);
});

final equipmentAlternativesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(cocktailRepositoryProvider).getEquipmentAlternatives();
});