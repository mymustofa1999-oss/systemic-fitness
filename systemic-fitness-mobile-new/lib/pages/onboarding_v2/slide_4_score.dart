import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../ColorCategory.dart';
import '../../util/sf_typography.dart';

// SF Onboarding v2 — Slide 4 / 4: "Tubuhmu punya skor".
// Reference: WhatsApp Image 2026-04-20 at 07.32.19 (1).jpeg
//
// Layout:
//  - Pill kecil "SYSTEM SCORE" (gold).
//  - Headline "Tubuhmu punya skor.\nDari 3 dimensi nyata."
//  - Subheadline "Olahraga · Nutrisi · Istirahat — diukur bersama..."
//  - Card hero (Midnight Blue) berisi:
//       Lingkaran gauge kiri (PieChart fl_chart) angka "81 OPTIMAL" emas.
//       3 baris breakdown (Gerak / Nutrisi / Istirahat) dengan progress bar.
//  - 4 mini-card grid 2x2 (35% Olahraga, 35% Nutrisi, 30% Istirahat,
//    "Update tiap sesi selesai").

class OnboardingSlide4 extends StatelessWidget {
  const OnboardingSlide4({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kSfWarmGold.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kSfWarmGold.withOpacity(0.45), width: 1),
            ),
            child: Text(
              'SYSTEM SCORE',
              style: SfTypography.label(
                fontSize: 11,
                color: kSfWarmGold,
                letterSpacing: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Tubuhmu punya skor.\nDari 3 dimensi nyata.',
            style: SfTypography.headline(
              fontSize: 28,
              color: Colors.white,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Olahraga · Nutrisi · Istirahat — diukur bersama, dioptimalkan bersama.',
            style: SfTypography.body(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // Hero score card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSfMidnightBlue,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gauge
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 36,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: 81,
                              color: kSfWarmGold,
                              radius: 8,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 19,
                              color: Colors.white.withOpacity(0.08),
                              radius: 8,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '81',
                            style: SfTypography.data(
                              fontSize: 28,
                              color: kSfWarmGold,
                            ),
                          ),
                          Text(
                            'OPTIMAL',
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
                ),
                const SizedBox(width: 18),
                // Breakdown bars
                Expanded(
                  child: Column(
                    children: const [
                      _ScoreRow(label: 'Gerak',    value: 83, color: kSfWarmGold),
                      SizedBox(height: 10),
                      _ScoreRow(label: 'Nutrisi',  value: 79, color: kSfSystemBlue),
                      SizedBox(height: 10),
                      _ScoreRow(label: 'Istirahat', value: 80, color: kSfDeepTeal),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Grid 2x2 mini-card
          Row(
            children: [
              Expanded(
                child: _DotCard(
                  dotColor: kSfWarmGold,
                  title: 'Olahraga',
                  subtitle: '35% skor',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DotCard(
                  dotColor: kSfSystemBlue,
                  title: 'Nutrisi',
                  subtitle: '35% skor',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DotCard(
                  dotColor: kSfDeepTeal,
                  title: 'Istirahat',
                  subtitle: '30% skor',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DotCard(
                  dotColor: kSfWarmGold,
                  title: 'Update tiap',
                  subtitle: 'sesi selesai',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
              value.toString(),
              style: SfTypography.data(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress bar
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
                widthFactor: value / 100,
                child: Container(
                  height: 5,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DotCard extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String subtitle;

  const _DotCard({
    required this.dotColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSfMidnightBlue.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SfTypography.body(
                    fontSize: 12.5,
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: SfTypography.body(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
