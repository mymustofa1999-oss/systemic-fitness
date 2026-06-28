import 'package:flutter/material.dart';

import '../../ColorCategory.dart';
import '../../util/sf_typography.dart';

// SF Onboarding v2 — Slide 2 / 4: "Bukan olahraga. Prescripsi fisiologis."
// Reference: WhatsApp Image 2026-04-20 at 07.32.19 (2).jpeg
//
// Layout:
//  - Card hitam atas dengan label "METODE SYSTEMIC FITNESS" gold + headline.
//  - Grid 2x2 dari 4 metode card (Load, Movement Pattern, Tempo/BPM,
//    Breathing Pattern). Tiap card punya icon ringan + judul + deskripsi
//    kecil + warna aksen di garis atas.
//  - Info box "3 sequence per sesi: FC → CC → MC".

class OnboardingSlide2 extends StatelessWidget {
  const OnboardingSlide2({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSfMidnightBlue,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'METODE SYSTEMIC FITNESS',
                  style: SfTypography.label(
                    fontSize: 11,
                    color: kSfWarmGold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bukan olahraga.',
                  style: SfTypography.headline(
                    fontSize: 28,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Prescripsi fisiologis.',
                  style: SfTypography.headline(
                    fontSize: 28,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Grid 2 x 2 metode
          Row(
            children: const [
              Expanded(
                child: _MethodCard(
                  accent: kSfWarmGold,
                  icon: Icons.crop_square_rounded,
                  title: 'Load',
                  description:
                      'Beban tepat mengaktifkan mekanotransduksi & pembentukan otot',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MethodCard(
                  accent: Color(0xFFB37AC0), // soft purple
                  icon: Icons.change_history_rounded,
                  title: 'Movement Pattern',
                  description:
                      'Pola gerakan memilih sistem fisiologis yang diaktifkan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MethodCard(
                  accent: kSfDeepTeal,
                  icon: Icons.favorite_rounded,
                  title: 'Tempo / BPM',
                  description:
                      'Ritme menentukan respons jantung & termogenesis selular',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MethodCard(
                  accent: kSfSystemBlue,
                  icon: Icons.air_rounded,
                  title: 'Breathing Pattern',
                  description:
                      'Napas mengatur tonus vagal, kortisol & oksigenasi',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Sequence info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: kSfWarmGold, width: 3),
              ),
            ),
            child: Text(
              '3 sequence per sesi: Functional Conditioning → '
              'Cardiorespiratory → Metabolic Conditioning. '
              'Durasinya berbeda untuk setiap kondisi — dikalibrasi khusus untukmu.',
              style: SfTypography.body(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String description;

  const _MethodCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: SfTypography.subheadline(
              fontSize: 14,
              color: kSfCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: SfTypography.body(
              fontSize: 11.5,
              color: kSfCharcoal.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
