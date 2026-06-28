import 'package:flutter/material.dart';

import '../../ColorCategory.dart';
import '../../util/sf_typography.dart';

// SF Onboarding v2 — Slide 1 / 4: "Sinyal yang perlu didengar".
// Reference: WhatsApp Image 2026-04-20 at 07.32.19.jpeg
//
// Layout:
//  - Pill kecil "SYSTEMIC FITNESS" (Warm Gold border + Charcoal/light bg).
//  - Headline besar 3-baris dengan kata "sinyal" highlight gold.
//  - Subheadline 1 baris.
//  - 4 bullet card kondisi (rounded, Midnight Blue bg) dengan dot warna gold.
//
// Background diset oleh wrapper (kSfDeepNavy).

class OnboardingSlide1 extends StatelessWidget {
  const OnboardingSlide1({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill brand
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kSfWarmGold.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kSfWarmGold.withOpacity(0.45), width: 1),
            ),
            child: Text(
              'SYSTEMIC FITNESS',
              style: SfTypography.label(
                fontSize: 11,
                color: kSfWarmGold,
                letterSpacing: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Headline editorial
          RichText(
            text: TextSpan(
              style: SfTypography.headline(
                fontSize: 30,
                color: Colors.white,
                height: 1.18,
              ),
              children: [
                const TextSpan(text: 'Tubuhmu masih aktif.\nTapi ada '),
                TextSpan(
                  text: 'sinyal',
                  style: SfTypography.headline(
                    fontSize: 30,
                    color: kSfWarmGold,
                    height: 1.18,
                  ),
                ),
                const TextSpan(text: '\nyang perlu didengar.'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Kondisi kesehatanmu butuh pendekatan yang lebih presisi dari sekadar olahraga biasa.',
            style: SfTypography.body(
              fontSize: 14,
              color: Colors.white.withOpacity(0.72),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // 4 bullet card kondisi
          _ConditionBullet(
            color: kSfWarmGold,
            text: 'Tensi, kolesterol, atau gula darah mulai tidak optimal',
          ),
          const SizedBox(height: 10),
          _ConditionBullet(
            color: kSfWarmGold,
            text:
                'Ada keluhan kesehatan yang mengganggu — sendi, asam urat, imun, atau kondisi kronis lainnya',
          ),
          const SizedBox(height: 10),
          _ConditionBullet(
            color: const Color(0xFFB37AC0), // soft purple — perimenopause
            text: 'Hormonal tidak seimbang — PCOS, tiroid, atau perimenopause',
          ),
          const SizedBox(height: 10),
          _ConditionBullet(
            color: kSfWarmGold,
            text:
                'Ingin optimalkan performa — stamina, kekuatan, dan vitalitas yang lebih konsisten',
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ConditionBullet extends StatelessWidget {
  final Color color;
  final String text;

  const _ConditionBullet({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSfMidnightBlue.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7, right: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: SfTypography.body(
                fontSize: 13.5,
                color: Colors.white.withOpacity(0.92),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
