import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../data/api_config.dart';
import '../../data/api_service.dart';
import '../../data/pref_data.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';

/// Waitlist screen untuk Level 0–1 / 2–3 yang program belum tersedia.
/// Source = 'level_0_3'. Menjoin endpoint /api/v2/tier4-waitlist.
class PhaseAWaitlistScreen extends StatefulWidget {
  const PhaseAWaitlistScreen({super.key});

  @override
  State<PhaseAWaitlistScreen> createState() => _PhaseAWaitlistScreenState();
}

class _PhaseAWaitlistScreenState extends State<PhaseAWaitlistScreen> {
  bool _submitting = false;

  Future<void> _join() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final user = await PrefData.getUser();
      if (user == null || user.email == null || user.email!.isEmpty) {
        throw Exception('Anda belum login.');
      }
      final body = <String, dynamic>{
        'full_name': user.fullName ?? 'Anonymous',
        'email': user.email,
        if (user.phone != null) 'phone': user.phone,
        'source': 'level_0_3',
        'note': 'Daftar dari mobile app — Phase A waitlist screen.',
      };
      await ApiService.post(ApiConfig.tier4Waitlist, body: body);
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Terima kasih — minat anda sudah tercatat. Kami akan menghubungi anda.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      context.go(AppRoutes.dashboard);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal mendaftarkan minat. Coba lagi.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = AssessmentV2Draft.instance.phaseA.physicalStatusLevel;
    final levelLabel = level == 'level_0_1'
        ? 'Level 0–1'
        : level == 'level_2_3'
            ? 'Level 2–3'
            : 'Level fungsional terbatas';

    return Scaffold(
      backgroundColor: kSfDeepNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
              child: Row(
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
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kSfWarmGold.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: kSfWarmGold.withOpacity(0.45)),
                      ),
                      child: Text(
                        'WAITLIST · $levelLabel',
                        style: SfTypography.label(
                          fontSize: 10,
                          color: kSfWarmGold,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Anda adalah\nalasan kami\nbergerak lebih cepat.',
                      style: SfTypography.headline(
                        fontSize: 30,
                        color: Colors.white,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda.',
                      style: SfTypography.body(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.78),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _InfoTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Daftar waitlist',
                      subtitle:
                          'Kami akan kabari saat program untuk kondisi anda siap.',
                    ),
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.play_circle_outline,
                      title: 'Bonus akses gratis',
                      subtitle:
                          'Modul "Gerakan dari Kursi" — video gentle movement untuk dilakukan dari posisi duduk.',
                    ),
                  ],
                ),
              ),
            ),

            // CTA
            Padding(
              padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _join,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSfWarmGold,
                        disabledBackgroundColor: kSfWarmGold.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : Text(
                              'Daftarkan Minat Saya',
                              style: SfTypography.ctaPrimary(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    child: Text(
                      'Lain kali saja',
                      style: SfTypography.body(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSfMidnightBlue.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kSfWarmGold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SfTypography.subheadline(
                    fontSize: 14, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: SfTypography.body(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.65),
                    height: 1.4,
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
