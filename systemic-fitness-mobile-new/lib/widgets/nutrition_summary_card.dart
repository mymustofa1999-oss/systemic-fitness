import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';

class NutritionSummaryCard extends StatelessWidget {
  final int currentCalories;
  final int targetCalories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;

  const NutritionSummaryCard({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    final calorieProgress = targetCalories > 0
        ? (currentCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              Text(
                '$currentCalories / $targetCalories kcal',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: calorieProgress,
              minHeight: 10,
              backgroundColor: primaryColor,
              valueColor: AlwaysStoppedAnimation<Color>(greenButton),
            ),
          ),

          // Macros section
          if (proteinG != null || carbsG != null || fatG != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (proteinG != null)
                  Expanded(
                    child: _macroBar(
                      'Protein',
                      proteinG!,
                      targetProtein,
                      const Color(0xFFE53935),
                    ),
                  ),
                if (proteinG != null && carbsG != null)
                  const SizedBox(width: 16),
                if (carbsG != null)
                  Expanded(
                    child: _macroBar(
                      'Carbs',
                      carbsG!,
                      targetCarbs,
                      const Color(0xFFFFA726),
                    ),
                  ),
                if (carbsG != null && fatG != null)
                  const SizedBox(width: 16),
                if (fatG != null)
                  Expanded(
                    child: _macroBar(
                      'Fat',
                      fatG!,
                      targetFat,
                      blueButton,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroBar(
    String label,
    double current,
    double? target,
    Color color,
  ) {
    final progress =
        (target != null && target > 0) ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: primaryColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          target != null
              ? '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g'
              : '${current.toStringAsFixed(0)}g',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 11,
            color: accentColor,
          ),
        ),
      ],
    );
  }
}
