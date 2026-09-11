import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class IngredientInput extends StatefulWidget {
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  final String hint;

  const IngredientInput({
    super.key,
    required this.items,
    required this.onChanged,
    this.hint = 'Add an ingredient...',
  });

  @override
  State<IngredientInput> createState() => _IngredientInputState();
}

class _IngredientInputState extends State<IngredientInput> {
  final _controller = TextEditingController();

  void _add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    widget.onChanged([...widget.items, trimmed]);
    _controller.clear();
  }

  void _remove(String item) {
    widget.onChanged(widget.items.where((i) => i != item).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.items
              .map((item) => Chip(
                    label: Text(item),
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: const TextStyle(color: AppColors.textPrimary),
                    deleteIconColor: AppColors.textSecondary,
                    onDeleted: () => _remove(item),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onSubmitted: _add,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, color: AppColors.premiumAccent),
              onPressed: () => _add(_controller.text),
            ),
          ),
        ),
      ],
    );
  }
}