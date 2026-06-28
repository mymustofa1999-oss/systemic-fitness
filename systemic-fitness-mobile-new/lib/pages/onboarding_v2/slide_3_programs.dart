import 'package:flutter/material.dart';

import '../../ColorCategory.dart';
import '../../util/sf_typography.dart';

// SF Onboarding v2 — Slide 3 / 4: "Program yang tepat untuk kondisimu".
// Reference: WhatsApp Image 2026-04-20 at 07.32.20.jpeg
//
// Layout:
//  - Subheadline kecil "DARI SATU ASESMEN, KAMU MENDAPAT" (gold).
//  - Headline editorial 2-baris "Program yang tepat\nuntuk kondisimu."
//  - 3 program card:
//      1. Condition-Specific Program (Level 4-5)
//      2. Preventive Optimization (Level 5)
//      3. Performance 35–60 (Advanced)
//    Tiap card: judul + tag level + deskripsi + 3 chip metadata.

class OnboardingSlide3 extends StatelessWidget {
  const OnboardingSlide3({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DARI SATU ASESMEN, KAMU MENDAPAT',
            style: SfTypography.label(
              fontSize: 11,
              color: kSfWarmGold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Program yang tepat\nuntuk kondisimu.',
            style: SfTypography.headline(
              fontSize: 28,
              color: Colors.white,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 22),

          _ProgramCard(
            title: 'Condition-Specific Program',
            tag: 'Level 4–5',
            tagColor: kSfWarmGold,
            description:
                'Ada kondisi medis aktif — dikurasi Health Consultant.',
            chips: [
              _ProgramChip(label: '60 mnt', sub: 'Full 2×/minggu'),
              _ProgramChip(label: '30 mnt', sub: 'Reset 2–3×/minggu'),
              _ProgramChip(label: 'Consultant', sub: 'Kurasi manual'),
            ],
          ),
          const SizedBox(height: 12),

          _ProgramCard(
            title: 'Preventive Optimization',
            tag: 'Level 5',
            tagColor: kSfDeepTeal,
            description:
                'Tanpa kondisi medis — otomatis, self-guided.',
            chips: [
              _ProgramChip(label: '60 mnt', sub: 'Full 2×/minggu'),
              _ProgramChip(label: '30 mnt', sub: 'Reset 2–3×/minggu'),
              _ProgramChip(label: 'Otomatis', sub: 'Mandiri'),
            ],
          ),
          const SizedBox(height: 12),

          _ProgramCard(
            title: 'Performance 35–60',
            tag: 'Advanced',
            tagColor: kSfSystemBlue,
            description:
                'Optimasi hormonal & performa — Women’s atau Men’s.',
            chips: [
              _ProgramChip(label: 'Women’s', sub: '35–45 / 46–60'),
              _ProgramChip(label: 'Men’s', sub: '35–45 / 46–60'),
              _ProgramChip(label: 'Otomatis', sub: 'Gender-specific'),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String title;
  final String tag;
  final Color tagColor;
  final String description;
  final List<_ProgramChip> chips;

  const _ProgramCard({
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.description,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: SfTypography.subheadline(
                    fontSize: 16,
                    color: kSfMidnightBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: SfTypography.label(
                    fontSize: 10,
                    color: tagColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: SfTypography.body(
              fontSize: 12.5,
              color: kSfCharcoal.withOpacity(0.7),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: chips[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgramChip extends StatelessWidget {
  final String label;
  final String sub;

  const _ProgramChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: kSfIceBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SfTypography.data(
              fontSize: 12,
              color: kSfMidnightBlue,
              weight: FontWeight.w500,
            ),
          ),
          Text(
            sub,
            style: SfTypography.body(
              fontSize: 10.5,
              color: kSfCharcoal.withOpacity(0.6),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
