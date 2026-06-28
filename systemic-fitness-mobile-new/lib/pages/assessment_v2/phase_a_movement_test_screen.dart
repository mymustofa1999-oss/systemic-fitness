import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../online_models/AssessmentV2Models.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';
import 'widgets/phase_progress_indicator.dart';

/// Basic Movement Test untuk Preventive path (Level 4-5 + no medical).
/// 3 gerakan self-report (skor 0–2 each, total max 6).
/// ≥4 → lanjut ke Phase B. ≤3 → diarahkan ke konsultasi gratis 15 menit.
class PhaseAMovementTestScreen extends StatefulWidget {
  const PhaseAMovementTestScreen({super.key});

  @override
  State<PhaseAMovementTestScreen> createState() =>
      _PhaseAMovementTestScreenState();
}

class _PhaseAMovementTestScreenState extends State<PhaseAMovementTestScreen> {
  late PhaseAMovementTest _draft;

  @override
  void initState() {
    super.initState();
    _draft = AssessmentV2Draft.instance.phaseA.movementTest ??
        PhaseAMovementTest();
  }

  // Track jawaban explicitly via flags lokal (default int 0 ambigu dgn jawaban "tidak bisa")
  final Set<String> _answered = {};

  bool get _canContinue => _answered.length == 3;

  void _onAnswer(String key, int value) {
    setState(() {
      _answered.add(key);
      switch (key) {
        case 'squat': _draft.squat = value; break;
        case 'hip_hinge': _draft.hipHinge = value; break;
        case 'overhead': _draft.overhead = value; break;
      }
    });
  }

  void _onContinue() {
    if (!_canContinue) {
      Fluttertoast.showToast(
        msg: 'Mohon jawab semua 3 gerakan dulu.',
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    AssessmentV2Draft.instance.phaseA.movementTest = _draft;

    // Skor < 4 → diarahkan ke konsultasi gratis (in-app: kasih toast +
    // lanjut ke phase B juga supaya tidak block flow). Bisa diperbaiki
    // dengan dialog di iterasi berikutnya.
    if (_draft.total < 4) {
      Fluttertoast.showToast(
        msg: 'Skor gerakan ${_draft.total}/6 — kami sarankan Konsultasi Online Gratis 15 menit. (Akan tersedia pada update berikutnya.)',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
    context.push(AppRoutes.assessmentV2PhaseB);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSfWarmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PhaseHeader(
              currentPhase: 0,
              title: 'Tes Gerakan Dasar',
              subProgress: '3 gerakan',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Text(
                    'Lakukan 3 gerakan ini sambil duduk atau berdiri di tempat yang aman, lalu pilih opsi yang paling cocok.',
                    style: SfTypography.body(
                      fontSize: 13.5,
                      color: kSfCharcoal.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _MovementQuestion(
                    no: '1',
                    title: 'Bodyweight Squat',
                    description: 'Berdiri tegak, lalu tekuk lutut sampai paha sejajar lantai (atau semampu anda), kembali ke posisi awal.',
                    selected: _answered.contains('squat') ? _draft.squat : null,
                    onChanged: (v) => _onAnswer('squat', v),
                  ),
                  const SizedBox(height: 18),
                  _MovementQuestion(
                    no: '2',
                    title: 'Hip Hinge',
                    description: 'Berdiri tegak, lutut sedikit menekuk. Bungkukkan badan dari pinggul (bukan punggung) seakan-akan mau ambil sesuatu di lantai.',
                    selected: _answered.contains('hip_hinge') ? _draft.hipHinge : null,
                    onChanged: (v) => _onAnswer('hip_hinge', v),
                  ),
                  const SizedBox(height: 18),
                  _MovementQuestion(
                    no: '3',
                    title: 'Overhead Reach',
                    description: 'Angkat kedua tangan lurus ke atas tanpa membusungkan dada atau menaikkan bahu (shrug).',
                    selected: _answered.contains('overhead') ? _draft.overhead : null,
                    onChanged: (v) => _onAnswer('overhead', v),
                  ),

                  if (_canContinue) ...[
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _draft.total >= 4
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _draft.total >= 4
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: _draft.total >= 4
                                ? Colors.green.shade700
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _draft.total >= 4
                                  ? 'Total skor anda ${_draft.total}/6 — siap lanjut ke Phase B.'
                                  : 'Total skor anda ${_draft.total}/6. Kami akan tetap arahkan anda ke Phase B, dan menyarankan Konsultasi Online Gratis 15 menit.',
                              style: SfTypography.body(
                                fontSize: 12.5,
                                color: _draft.total >= 4
                                    ? Colors.green.shade800
                                    : Colors.amber.shade900,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            V2BottomCta(
              label: 'Lanjut ke Phase B  →',
              onPressed: _canContinue ? _onContinue : null,
              hint: _canContinue ? null : 'Jawab semua 3 gerakan untuk lanjut.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementQuestion extends StatelessWidget {
  final String no;
  final String title;
  final String description;
  final int? selected;
  final ValueChanged<int> onChanged;

  const _MovementQuestion({
    required this.no,
    required this.title,
    required this.description,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: kSfWarmGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  no,
                  style: SfTypography.label(
                    fontSize: 11, color: kSfWarmGoldDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: SfTypography.subheadline(
                  fontSize: 16, color: kSfCharcoal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            description,
            style: SfTypography.body(
              fontSize: 12.5,
              color: kSfCharcoal.withOpacity(0.6),
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 12),
        V2SelectCard<int>(
          value: 2,
          groupValue: selected,
          label: 'Bisa penuh — tanpa kompensasi atau nyeri',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<int>(
          value: 1,
          groupValue: selected,
          label: 'Bisa, tapi dengan kompensasi (tubuh menyesuaikan)',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<int>(
          value: 0,
          groupValue: selected,
          label: 'Tidak bisa atau terasa nyeri',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
