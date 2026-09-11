import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/bartender_models.dart';

class SuggestionCard extends StatelessWidget {
  final SuggestedCocktail suggestion;

  const SuggestionCard({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(suggestion.name,
                    style: const TextStyle(
                        color: AppColors.premiumAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${(suggestion.matchScore * 100).round()}% match',
                    style: const TextStyle(color: AppColors.kenyanAccent, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(suggestion.explanation, style: const TextStyle(color: AppColors.textPrimary)),
          if (suggestion.missingIngredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Missing: ${suggestion.missingIngredients.join(', ')}',
              style: const TextStyle(color: AppColors.primaryAction, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}