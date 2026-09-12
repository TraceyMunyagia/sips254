import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/bartender_models.dart';
import '../providers/bartender_providers.dart';
import 'widgets/ingredient_input.dart';

class PunchModeScreen extends ConsumerStatefulWidget {
  const PunchModeScreen({super.key});

  @override
  ConsumerState<PunchModeScreen> createState() => _PunchModeScreenState();
}

class _PunchModeScreenState extends ConsumerState<PunchModeScreen> {
  int _people = 10;
  List<String> _spirits = [];
  List<String> _mixers = [];
  String _strength = 'medium';
  String _sweetness = 'sweet';

  PunchResult? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _generate() async {
    if (_spirits.isEmpty) {
      setState(() => _error = 'Add at least one spirit.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await ref.read(bartenderRepositoryProvider).getPunchRecommendation(
            people: _people,
            availableSpirits: _spirits,
            availableMixers: _mixers,
            strength: _strength,
            sweetness: _sweetness,
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
      appBar: AppBar(title: const Text('Punch Mode')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('How many people?',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _people.toDouble(),
                  min: 2,
                  max: 50,
                  divisions: 48,
                  activeColor: AppColors.premiumAccent,
                  onChanged: (v) => setState(() => _people = v.round()),
                ),
              ),
              SizedBox(width: 48, child: Text('$_people', style: const TextStyle(color: AppColors.textPrimary))),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Available spirits', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IngredientInput(items: _spirits, onChanged: (v) => setState(() => _spirits = v), hint: 'e.g. Dark Rum'),

          const SizedBox(height: 16),
          const Text('Available mixers', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IngredientInput(items: _mixers, onChanged: (v) => setState(() => _mixers = v), hint: 'e.g. Pineapple Juice'),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _strength,
                  decoration: const InputDecoration(labelText: 'Strength'),
                  dropdownColor: AppColors.surfaceElevated,
                  items: const [
                    DropdownMenuItem(value: 'mild', child: Text('Mild')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'strong', child: Text('Strong')),
                  ],
                  onChanged: (v) => setState(() => _strength = v ?? 'medium'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sweetness,
                  decoration: const InputDecoration(labelText: 'Sweetness'),
                  dropdownColor: AppColors.surfaceElevated,
                  items: const [
                    DropdownMenuItem(value: 'dry', child: Text('Dry')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'sweet', child: Text('Sweet')),
                  ],
                  onChanged: (v) => setState(() => _sweetness = v ?? 'sweet'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _generate,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Generate Punch Recipe'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.primaryAction)),
          ],

          if (_result != null)
            ..._result!.recommendations.map((rec) => Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec.name,
                          style: const TextStyle(
                              color: AppColors.premiumAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(rec.explanation, style: const TextStyle(color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Text('For ${rec.scaledRecipe.targetPeople} people (×${rec.scaledRecipe.multiplier}):',
                          style: const TextStyle(color: AppColors.kenyanAccent, fontWeight: FontWeight.bold)),
                      ...rec.scaledRecipe.scaledIngredients.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${i.name}: ${i.scaledAmount}${i.unit}',
                                style: const TextStyle(color: AppColors.textSecondary)),
                          )),
                      const SizedBox(height: 12),
                      Text('Method: ${rec.scaledRecipe.instructions}',
                          style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
                      if (rec.scaledRecipe.garnish != null) ...[
                        const SizedBox(height: 8),
                        Text('Garnish: ${rec.scaledRecipe.garnish}',
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}