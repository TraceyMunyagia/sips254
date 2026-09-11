import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AttributeBar extends StatelessWidget {
  final String label;
  final int value; // 0-10

  const AttributeBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 10,
                minHeight: 8,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation(AppColors.premiumAccent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value/10', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}