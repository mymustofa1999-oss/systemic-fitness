import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';

class ProgramCard extends StatelessWidget {
  final String name;
  final String? difficulty;
  final String? goal;
  final int? durationWeeks;
  final VoidCallback onTap;

  const ProgramCard({
    super.key,
    required this.name,
    this.difficulty,
    this.goal,
    this.durationWeeks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: blueButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: blueButton,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (goal != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          goal!,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 13,
                            color: subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: subTextColor,
                  size: 22,
                ),
              ],
            ),
            if (difficulty != null || durationWeeks != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (difficulty != null) ...[
                    _difficultyBadge(difficulty!),
                    const SizedBox(width: 10),
                  ],
                  if (durationWeeks != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: subTextColor),
                        const SizedBox(width: 4),
                        Text(
                          '$durationWeeks weeks',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 13,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _difficultyBadge(String level) {
    Color badgeColor;
    switch (level.toLowerCase()) {
      case 'beginner':
        badgeColor = greenButton;
        break;
      case 'intermediate':
        badgeColor = Colors.orange;
        break;
      case 'advanced':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = blueButton;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: badgeColor,
        ),
      ),
    );
  }
}
