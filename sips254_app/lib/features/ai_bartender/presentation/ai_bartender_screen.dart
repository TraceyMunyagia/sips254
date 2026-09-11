import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/bartender_models.dart';
import '../providers/bartender_providers.dart';
import 'widgets/ingredient_input.dart';
import 'widgets/suggestion_card.dart';

class AiBartenderScreen extends ConsumerStatefulWidget {
  const AiBartenderScreen({super.key});

  @override
  ConsumerState<AiBartenderScreen> createState() => _AiBartenderScreenState();
}

class _AiBartenderScreenState extends ConsumerState<AiBartenderScreen> {
  List<String> _spirits = [];
  List<String> _ingredients = [];
  String _strengthPref = 'medium';
  String _sweetnessPref = 'medium';

  BartenderResult? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _makeMyCocktail() async {
    if (_spirits.isEmpty && _ingredients.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await ref.read(bartenderRepositoryProvider).getSuggestionsFromIngredients(
            ingredients: _ingredients,
            spirits: _spirits,
            preferences: {
              'strength': _strengthPref,
              'sweetness': _sweetnessPref,
            },
          );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'Something went wrong: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Bartender')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("What's in your bar?",
              style: TextStyle(color: AppColors.premiumAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Tell me what you have and I'll help you make something.",
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          const Text('Spirits', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IngredientInput(
            items: _spirits,
            onChanged: (v) => setState(() => _spirits = v),
            hint: 'e.g. Vodka, Kenya Cane...',
          ),

          const SizedBox(height: 20),
          const Text('Other ingredients',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IngredientInput(
            items: _ingredients,
            onChanged: (v) => setState(() => _ingredients = v),
            hint: 'e.g. Lime juice, passion fruit...',
          ),

          const SizedBox(height: 20),
          const Text('Preferences', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _strengthPref,
                  decoration: const InputDecoration(labelText: 'Strength'),
                  dropdownColor: AppColors.surfaceElevated,
                  items: const [
                    DropdownMenuItem(value: 'mild', child: Text('Mild')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'strong', child: Text('Strong')),
                  ],
                  onChanged: (v) => setState(() => _strengthPref = v ?? 'medium'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sweetnessPref,
                  decoration: const InputDecoration(labelText: 'Sweetness'),
                  dropdownColor: AppColors.surfaceElevated,
                  items: const [
                    DropdownMenuItem(value: 'dry', child: Text('Dry')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'sweet', child: Text('Sweet')),
                  ],
                  onChanged: (v) => setState(() => _sweetnessPref = v ?? 'medium'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _makeMyCocktail,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create My Cocktail'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.primaryAction)),
          ],

          if (_result != null) ...[
            const SizedBox(height: 24),
            if (_result!.suggestions.isEmpty)
              const Text('No matches found with what you have.',
                  style: TextStyle(color: AppColors.textSecondary))
            else
              ..._result!.suggestions.map((s) => SuggestionCard(suggestion: s)),
            if (_result!.shoppingSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Shopping suggestions',
                  style: TextStyle(color: AppColors.premiumAccent, fontWeight: FontWeight.bold)),
              ..._result!.shoppingSuggestions.map((s) => Text('• $s',
                  style: const TextStyle(color: AppColors.textSecondary))),
            ],
          ],
        ],
      ),
    );
  }
}