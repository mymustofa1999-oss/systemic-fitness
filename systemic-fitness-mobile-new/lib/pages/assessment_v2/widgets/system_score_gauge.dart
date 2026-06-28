import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../ColorCategory.dart';
import '../../../util/sf_typography.dart';

/// Circular gauge untuk System Score 0..100.
/// Reuse pattern dari onboarding slide 4.
class SystemScoreGauge extends StatelessWidget {
  final double score;
  final String tier; // OPTIMAL | STABLE | COMPROMISED | CRITICAL
  final double size;

  const SystemScoreGauge({
    super.key,
    required this.score,
    required this.tier,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.34,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  value: clamped,
                  color: kSfWarmGold,
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 100 - clamped,
                  color: Colors.white.withOpacity(0.08),
                  radius: 12,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clamped > 0 ? clamped.toStringAsFixed(0) : '—',
                style: SfTypography.data(
                  fontSize: size * 0.32,
                  color: kSfWarmGold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tier,
                style: SfTypography.label(
                  fontSize: 9,
                  color: kSfWarmGold.withOpacity(0.85),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progress bar single dimension (Movement / Nutrition / Rest).
class ScoreBreakdownBar extends StatelessWidget {
  final String label;
  final double? value;
  final Color color;

  const ScoreBreakdownBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ((value ?? 0).clamp(0, 100) / 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: SfTypography.body(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.78),
                ),
              ),
            ),
            Text(
              value != null ? value!.toStringAsFixed(0) : '—',
              style: SfTypography.data(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            children: [
              Container(
                height: 5,
                width: double.infinity,
                color: Colors.white.withOpacity(0.08),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(height: 5, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
