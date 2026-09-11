import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/recipe_providers.dart';
import 'widgets/attribute_bar.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String cocktailId;

  const RecipeDetailScreen({super.key, required this.cocktailId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _showHomeAlternatives = false;

  static const Map<String, String> _toolSwap = {
    'ml': 'ml (≈ a standard shot measure per 50ml)',
  };

  @override
  Widget build(BuildContext context) {
    final cocktailAsync = ref.watch(cocktailDetailProvider(widget.cocktailId));
    final equipmentAsync = ref.watch(equipmentAlternativesProvider);

    return Scaffold(
      body: cocktailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load recipe: $e')),
        data: (cocktail) {
          if (cocktail == null) return const Center(child: Text('Recipe not found'));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: cocktail.photoUrl != null
                      ? Image.network(cocktail.photoUrl!, fit: BoxFit.cover)
                      : Container(color: AppColors.surfaceElevated),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(cocktail.name,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                          ),
                          if (cocktail.isKenyanInspired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.kenyanAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🇰🇪 Kenyan',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                            ),
                        ],
                      ),
                      if (cocktail.description != null) ...[
                        const SizedBox(height: 8),
                        Text(cocktail.description!,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: 20),

                      const Text('Profile',
                          style: TextStyle(color: AppColors.premiumAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AttributeBar(label: 'Strength', value: cocktail.strength),
                      AttributeBar(label: 'Sweetness', value: cocktail.sweetness),
                      AttributeBar(label: 'Sourness', value: cocktail.sourness),
                      AttributeBar(label: 'Bitterness', value: cocktail.bitterness),
                      AttributeBar(label: 'Fruitiness', value: cocktail.fruitiness),
                      AttributeBar(label: 'Fizz', value: cocktail.fizz),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ingredients',
                              style: TextStyle(
                                  color: AppColors.premiumAccent, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Text('Home mode',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              Switch(
                                value: _showHomeAlternatives,
                                activeThumbColor: AppColors.kenyanAccent,
                                onChanged: (v) => setState(() => _showHomeAlternatives = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ...cocktail.ingredients.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(i.name, style: const TextStyle(color: AppColors.textPrimary)),
                                Text(
                                  '${i.amount}${_showHomeAlternatives ? (_toolSwap[i.unit] ?? i.unit) : i.unit}',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )),

                      if (_showHomeAlternatives) ...[
                        const SizedBox(height: 16),
                        const Text('Equipment substitutes',
                            style: TextStyle(color: AppColors.premiumAccent, fontWeight: FontWeight.bold)),
                        equipmentAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (list) => Column(
                            children: list
                                .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        '${e['professional_tool']} → ${e['home_alternative']}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Text('Method',
                          style: TextStyle(color: AppColors.premiumAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(cocktail.instructions,
                          style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),

                      if (cocktail.garnish != null) ...[
                        const SizedBox(height: 16),
                        Text('Garnish: ${cocktail.garnish}',
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}