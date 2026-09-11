import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../recipes/providers/recipe_providers.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _garnishController = TextEditingController();

  int _strength = 5, _sweetness = 5, _sourness = 5, _bitterness = 0, _fruitiness = 5, _fizz = 0;
  int _difficulty = 3, _servings = 1;
  bool _isKenyanInspired = false;
  File? _photo;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _nameController.text.trim().isEmpty || _instructionsController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadCocktailPhoto(_photo!, user.id);
      }

      await ref.read(cocktailRepositoryProvider).createCocktail(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            instructions: _instructionsController.text.trim(),
            strength: _strength,
            sweetness: _sweetness,
            sourness: _sourness,
            bitterness: _bitterness,
            fruitiness: _fruitiness,
            fizz: _fizz,
            difficulty: _difficulty,
            servings: _servings,
            garnish: _garnishController.text.trim().isEmpty ? null : _garnishController.text.trim(),
            isKenyanInspired: _isKenyanInspired,
            createdBy: user.id,
            photoUrl: photoUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe published!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _slider(String label, int value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value', style: const TextStyle(color: AppColors.textSecondary)),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.premiumAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Recipe')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                image: _photo != null
                    ? DecorationImage(image: FileImage(_photo!), fit: BoxFit.cover)
                    : null,
              ),
              child: _photo == null
                  ? const Center(
                      child: Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 36))
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Cocktail name')),
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            decoration: const InputDecoration(labelText: 'Instructions'),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(controller: _garnishController, decoration: const InputDecoration(labelText: 'Garnish')),
          const SizedBox(height: 20),
          _slider('Strength', _strength, (v) => setState(() => _strength = v.round())),
          _slider('Sweetness', _sweetness, (v) => setState(() => _sweetness = v.round())),
          _slider('Sourness', _sourness, (v) => setState(() => _sourness = v.round())),
          _slider('Bitterness', _bitterness, (v) => setState(() => _bitterness = v.round())),
          _slider('Fruitiness', _fruitiness, (v) => setState(() => _fruitiness = v.round())),
          _slider('Fizz', _fizz, (v) => setState(() => _fizz = v.round())),
          _slider('Difficulty', _difficulty, (v) => setState(() => _difficulty = v.round())),
          SwitchListTile(
            title: const Text('Kenyan-inspired', style: TextStyle(color: AppColors.textPrimary)),
            value: _isKenyanInspired,
            activeThumbColor: AppColors.kenyanAccent,
            onChanged: (v) => setState(() => _isKenyanInspired = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publish Recipe'),
          ),
        ],
      ),
    );
  }
}