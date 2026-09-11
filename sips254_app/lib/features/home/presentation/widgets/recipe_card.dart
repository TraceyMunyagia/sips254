import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/cocktail_model.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../comments/providers/social_providers.dart';

class RecipeCard extends ConsumerWidget {
  final Cocktail cocktail;

  const RecipeCard({super.key, required this.cocktail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final likeCountAsync = ref.watch(likeCountProvider(cocktail.id));

    return GestureDetector(
      onTap: () => context.push('/recipe/${cocktail.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: cocktail.photoUrl != null
                  ? Image.network(cocktail.photoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 200, color: AppColors.background),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(cocktail.name,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      if (cocktail.isKenyanInspired)
                        const Text('🇰🇪', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.favorite_border, color: AppColors.primaryAction, size: 20),
                        onPressed: user == null
                            ? null
                            : () async {
                                final liked = await ref.read(socialRepositoryProvider).isLiked(cocktail.id, user.id);
                                await ref.read(socialRepositoryProvider).toggleLike(cocktail.id, user.id, liked);
                                ref.invalidate(likeCountProvider(cocktail.id));
                              },
                      ),
                      likeCountAsync.when(
                        data: (count) => Text('$count',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.bookmark_border, color: AppColors.premiumAccent, size: 20),
                        onPressed: user == null
                            ? null
                            : () async {
                                final saved = await ref.read(socialRepositoryProvider).isSaved(cocktail.id, user.id);
                                await ref.read(socialRepositoryProvider).toggleSave(cocktail.id, user.id, saved);
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}