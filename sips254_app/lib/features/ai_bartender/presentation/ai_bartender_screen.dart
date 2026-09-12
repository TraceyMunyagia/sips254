import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/bartender_models.dart';
import '../providers/bartender_providers.dart';
import 'widgets/ingredient_input.dart';
import 'widgets/suggestion_card.dart';
import 'punch_mode_screen.dart';

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
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('AI Bartender'),
        bottom: const TabBar(
          indicatorColor: AppColors.premiumAccent,
          labelColor: AppColors.premiumAccent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'By Ingredient'),
            Tab(text: 'Punch Mode'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _buildIngredientMode(),
          const PunchModeScreen(),
        ],
      ),
    ),
  );
}

Widget _buildIngredientMode() {
  return ListView(
    padding: const EdgeInsets.all(20),
    children: [
      // ... existing body content from the ListView goes here, unchanged
    ],
  );
}
}