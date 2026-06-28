import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import '../../data/pref_data.dart';
import '../../models/user_model.dart';

/// Landing page Assessment v2 — gambaran 3 phase + estimasi waktu + CTA mulai.
class AssessmentV2IntroScreen extends StatelessWidget {
  const AssessmentV2IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kSfDeepNavy,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kSfWarmWhite,
        body: SafeArea(
          child: Column(
            children: [
              _Hero(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yang akan anda lalui',
                        style: SfTypography.subheadline(
                          fontSize: 18,
                          color: kSfCharcoal,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PhaseCard(
                        index: 'A',
                        title: 'Penilaian Kondisi',
                        time: '~2 menit',
                        description:
                            '3 pertanyaan tentang kondisi fisik, kondisi medis (jika ada), dan tujuan utama anda.',
                        color: kSfWarmGold,
                      ),
                      const SizedBox(height: 12),
                      _PhaseCard(
                        index: 'B',
                        title: 'Pola Tidur & Aktivitas',
                        time: '~3 menit',
                        description:
                            '10 pertanyaan untuk menentukan Rest Score & jadwal sesi yang optimal (Chronobiology Window).',
                        color: kSfSystemBlue,
                      ),
                      const SizedBox(height: 12),
                      _PhaseCard(
                        index: 'C',
                        title: 'Pola Makan & Gizi',
                        time: '~2 menit',
                        description:
                            '7 pertanyaan untuk Nutrition Score & rekomendasi gizi yang dipersonalisasi.',
                        color: kSfDeepTeal,
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kSfIceBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lock_outline,
                                size: 18, color: kSfMidnightBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Jawaban anda hanya digunakan untuk mempersonalisasi program. Tidak dibagikan ke pihak ketiga.',
                                style: SfTypography.body(
                                  fontSize: 12.5,
                                  color: kSfMidnightBlue,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(color: kSfDeepNavy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kSfWarmGold.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kSfWarmGold.withOpacity(0.45)),
            ),
            child: Text(
              'ASESMEN SISTEMIK',
              style: SfTypography.label(
                fontSize: 10,
                color: kSfWarmGold,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Mari kita pahami\nsistem tubuh anda.',
            style: SfTypography.headline(
              fontSize: 26, color: Colors.white, height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sekitar 7 menit. Anda dapat berhenti kapan saja — jawaban tersimpan otomatis.',
            style: SfTypography.body(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final String index;
  final String title;
  final String time;
  final String description;
  final Color color;

  const _PhaseCard({
    required this.index,
    required this.title,
    required this.time,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                index,
                style: SfTypography.headline(
                  fontSize: 22, color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: SfTypography.subheadline(
                          fontSize: 15.5, color: kSfCharcoal,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: SfTypography.body(
                        fontSize: 11.5,
                        color: kSfCharcoal.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: SfTypography.body(
                    fontSize: 12.5,
                    color: kSfCharcoal.withOpacity(0.7),
                    height: 1.45,
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

class _BottomBar extends StatefulWidget {
  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _isLoading = false;

  Future<void> _checkProfileAndProceed() async {
    setState(() => _isLoading = true);
    final UserModel? user = await PrefData.getUser();
    setState(() => _isLoading = false);

    if (user == null) {
      context.push(AppRoutes.login);
      return;
    }

    final dob = user.profile?.dateOfBirth;
    final height = user.profile?.heightCm;

    if (dob == null || dob.isEmpty || height == null || height <= 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Lengkapi Profil'),
          content: const Text(
              'Untuk mendapatkan rekomendasi program yang akurat, mohon lengkapi Tanggal Lahir dan Tinggi Badan anda di profil terlebih dahulu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(c);
                context.push(AppRoutes.editProfile);
              },
              child: const Text('Edit Profil'),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      context.push(AppRoutes.assessmentV2PhaseA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: kSfWarmWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _checkProfileAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kSfWarmGold,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Mulai Asesmen  →',
                  style: SfTypography.ctaPrimary(),
                ),
        ),
      ),
    );
  }
}
