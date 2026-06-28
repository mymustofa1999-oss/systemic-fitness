import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';

class WorkoutCard extends StatelessWidget {
  final String name;
  final String? type;
  final int? duration;
  final int? exerciseCount;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.name,
    this.type,
    this.duration,
    this.exerciseCount,
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: greenButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center,
                color: greenButton,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (type != null) ...[
                        _infoChip(type!),
                        const SizedBox(width: 8),
                      ],
                      if (duration != null) ...[
                        _infoTag(Icons.timer_outlined, '$duration min'),
                        const SizedBox(width: 8),
                      ],
                      if (exerciseCount != null)
                        _infoTag(Icons.list, '$exerciseCount exercises'),
                    ],
                  ),
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
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: blueButton.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: blueButton,
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: subTextColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 12,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}
