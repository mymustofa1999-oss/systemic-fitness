import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';

class ExerciseCard extends StatelessWidget {
  final String name;
  final List<String>? muscleGroup;
  final String? equipment;
  final int? sets;
  final int? reps;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.name,
    this.muscleGroup,
    this.equipment,
    this.sets,
    this.reps,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sports_gymnastics,
                color: accentColor,
                size: 22,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (muscleGroup != null && muscleGroup!.isNotEmpty)
                        Flexible(
                          child: Text(
                            muscleGroup!.join(', '),
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 12,
                              color: subTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (equipment != null) ...[
                        if (muscleGroup != null && muscleGroup!.isNotEmpty)
                          Text(
                            '  |  ',
                            style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        Text(
                          equipment!,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (sets != null || reps != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _setsRepsLabel(),
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                color: subTextColor,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _setsRepsLabel() {
    if (sets != null && reps != null) {
      return '${sets}x$reps';
    } else if (sets != null) {
      return '$sets sets';
    } else {
      return '$reps reps';
    }
  }
}
