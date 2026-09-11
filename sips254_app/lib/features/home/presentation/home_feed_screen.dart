import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../recipes/providers/recipe_providers.dart';
import 'widgets/recipe_card.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cocktailsAsync = ref.watch(publishedCocktailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIPS254',
            style: TextStyle(color: AppColors.premiumAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(publishedCocktailsProvider),
        child: cocktailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load feed: $e')),
          data: (cocktails) {
            if (cocktails.isEmpty) {
              return const Center(
                child: Text('No recipes yet', style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cocktails.length,
              itemBuilder: (context, index) => RecipeCard(cocktail: cocktails[index]),
            );
          },
        ),
      ),
    );
  }
}