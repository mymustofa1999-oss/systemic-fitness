import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../data/api_config.dart';
import '../../data/api_service.dart';
import '../../online_models/AssessmentV2Models.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';
import 'widgets/condition_picker.dart';
import 'widgets/phase_progress_indicator.dart';

/// Phase A screen — 3 pertanyaan dengan reveal-progressively + branching.
class PhaseAScreen extends StatefulWidget {
  const PhaseAScreen({super.key});

  @override
  State<PhaseAScreen> createState() => _PhaseAScreenState();
}

class _PhaseAScreenState extends State<PhaseAScreen> {
  late PhaseAInput _draft;
  String? _classificationLabel;
  String? _specificConditionLabel;

  @override
  void initState() {
    super.initState();
    // Reset draft saat intro masuk Phase A baru, kalau dari intro.
    _draft = AssessmentV2Draft.instance.phaseA;
  }

  // ─── Q1 ─────────────────────────────────────────────────────────

  void _setLevel(String level) {
    setState(() {
      _draft.physicalStatusLevel = level;
      // Reset cabang ketika level berubah
      _draft.hasMedicalCondition = false;
      _draft.classificationSlug = null;
      _draft.specificConditionSlug = null;
      _draft.gender = null;
      _draft.ageBucket = null;
      _draft.primaryGoal = null;
      _classificationLabel = null;
      _specificConditionLabel = null;
    });

    // Level 0-3 → langsung ke waitlist screen
    if (level == 'level_0_1' || level == 'level_2_3') {
      Future.microtask(() {
        if (mounted) context.push(AppRoutes.assessmentV2Waitlist);
      });
    }
  }

  // ─── Q2 ─────────────────────────────────────────────────────────

  void _setHasMedical(bool v) {
    setState(() {
      _draft.hasMedicalCondition = v;
      // Reset sub-fields
      _draft.classificationSlug = null;
      _draft.specificConditionSlug = null;
      _draft.gender = null;
      _draft.ageBucket = null;
      _draft.primaryGoal = null;
      _classificationLabel = null;
      _specificConditionLabel = null;
    });
  }

  Future<void> _pickClassification() async {
    final slug = await showClassificationPicker(context);
    if (slug == null || !mounted) return;

    // Lookup label dari endpoint master (cached oleh ApiService)
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.masterConditionClassifications,
      );
      final List<dynamic> data = res['data'] ?? const [];
      final found = data.firstWhere(
        (e) => (e as Map)['slug'] == slug,
        orElse: () => null,
      );
      setState(() {
        _draft.classificationSlug = slug;
        _classificationLabel = found != null ? found['label'] as String : slug;
        _draft.specificConditionSlug = null;
        _specificConditionLabel = null;
      });
    } catch (_) {
      setState(() {
        _draft.classificationSlug = slug;
        _classificationLabel = slug;
      });
    }
  }

  Future<void> _pickSpecificCondition() async {
    if (_draft.classificationSlug == null) return;
    final slug = await showSpecificConditionPicker(
      context,
      classificationSlug: _draft.classificationSlug!,
    );
    if (slug == null || !mounted) return;

    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.masterSpecificConditions,
        queryParams: {'classification': _draft.classificationSlug!},
      );
      final List<dynamic> data = res['data'] ?? const [];
      final found = data.firstWhere(
        (e) => (e as Map)['slug'] == slug,
        orElse: () => null,
      );
      setState(() {
        _draft.specificConditionSlug = slug;
        _specificConditionLabel = found != null ? found['label'] as String : slug;
      });
    } catch (_) {
      setState(() {
        _draft.specificConditionSlug = slug;
        _specificConditionLabel = slug;
      });
    }
  }

  // ─── Validation + Submit ────────────────────────────────────────

  bool get _canContinue {
    if (_draft.physicalStatusLevel == 'level_0_1' ||
        _draft.physicalStatusLevel == 'level_2_3') {
      return false; // Should never get here (waitlist intercepts)
    }
    if (_draft.hasMedicalCondition) {
      // Need classification + specific + primary_goal
      return _draft.classificationSlug != null &&
          _draft.specificConditionSlug != null &&
          _draft.primaryGoal != null;
    } else {
      // No medical → need gender + age_bucket
      return _draft.gender != null && _draft.ageBucket != null;
    }
  }

  void _onContinue() {
    if (!_canContinue) {
      Fluttertoast.showToast(
        msg: 'Mohon lengkapi semua jawaban dulu.',
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Save to draft (sudah ke-update via reference, tapi explicit)
    AssessmentV2Draft.instance.phaseA = _draft;

    // Preventive path (Level 4-5 + no medical) → movement test dulu
    if (!_draft.hasMedicalCondition) {
      context.push(AppRoutes.assessmentV2Movement);
    } else {
      // Condition-specific path → langsung ke Phase B
      context.push(AppRoutes.assessmentV2PhaseB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showQ2 = _draft.physicalStatusLevel == 'level_4_5_perf';
    final showQ3 = showQ2 && _draft.hasMedicalCondition;
    final showGenderAge = showQ2 && !_draft.hasMedicalCondition;

    return Scaffold(
      backgroundColor: kSfWarmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PhaseHeader(
              currentPhase: 0,
              title: 'Penilaian Kondisi',
              subProgress: '~3 pertanyaan',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  // Q1
                  _Question(
                    no: 'A1',
                    label: 'Bagaimana kondisi gerak anda saat ini?',
                    description: 'Pilih yang paling mendekati keadaan sekarang.',
                    children: [
                      V2SelectCard<String>(
                        value: 'level_0_1',
                        groupValue: _draft.physicalStatusLevel,
                        label: 'Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit.',
                        hint: 'Akan diarahkan ke waitlist program.',
                        onChanged: _setLevel,
                      ),
                      const SizedBox(height: 8),
                      V2SelectCard<String>(
                        value: 'level_2_3',
                        groupValue: _draft.physicalStatusLevel,
                        label: 'Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan.',
                        hint: 'Akan diarahkan ke waitlist program.',
                        onChanged: _setLevel,
                      ),
                      const SizedBox(height: 8),
                      V2SelectCard<String>(
                        value: 'level_4_5_perf',
                        groupValue: _draft.physicalStatusLevel,
                        label: 'Saya bisa berjalan, tapi gerakan fisik saya masih sangat terbatas dan stamina rendah.',
                        hint: 'Lanjut ke pertanyaan berikutnya.',
                        onChanged: _setLevel,
                      ),
                    ],
                  ),

                  // Q2
                  if (showQ2) ...[
                    const SizedBox(height: 28),
                    _Question(
                      no: 'A2',
                      label: 'Apakah anda memiliki kondisi medis aktif?',
                      description: 'Membantu kami menyesuaikan program dengan kondisi anda.',
                      children: [
                        V2SelectCard<bool>(
                          value: true,
                          groupValue: _draft.hasMedicalCondition,
                          label: 'Ya — ada gangguan kondisi kesehatan',
                          onChanged: _setHasMedical,
                        ),
                        const SizedBox(height: 8),
                        V2SelectCard<bool>(
                          value: false,
                          groupValue: _draft.hasMedicalCondition,
                          label: 'Tidak ada kondisi medis aktif',
                          onChanged: _setHasMedical,
                        ),
                      ],
                    ),
                  ],

                  // Q2 cabang YA — pilih klasifikasi + kondisi spesifik
                  if (showQ2 && _draft.hasMedicalCondition) ...[
                    const SizedBox(height: 18),
                    _PickerField(
                      label: 'Klasifikasi kondisi',
                      value: _classificationLabel,
                      placeholder: 'Pilih klasifikasi',
                      onTap: _pickClassification,
                    ),
                    const SizedBox(height: 10),
                    _PickerField(
                      label: 'Kondisi spesifik',
                      value: _specificConditionLabel,
                      placeholder: _draft.classificationSlug == null
                          ? 'Pilih klasifikasi terlebih dulu'
                          : 'Pilih kondisi',
                      enabled: _draft.classificationSlug != null,
                      onTap: _pickSpecificCondition,
                    ),
                  ],

                  // Q2 cabang TIDAK — Gender + Age bucket
                  if (showGenderAge) ...[
                    const SizedBox(height: 18),
                    _Question(
                      no: 'A2.1',
                      label: 'Pilih program gender',
                      children: [
                        V2SelectCard<String>(
                          value: 'women',
                          groupValue: _draft.gender,
                          label: 'Program Wanita',
                          hint: 'Optimasi hormon, stamina & vitalitas feminitas',
                          onChanged: (v) => setState(() => _draft.gender = v),
                        ),
                        const SizedBox(height: 8),
                        V2SelectCard<String>(
                          value: 'men',
                          groupValue: _draft.gender,
                          label: 'Program Pria',
                          hint: 'Optimasi testosteron, massa otot & stamina maskulin',
                          onChanged: (v) => setState(() => _draft.gender = v),
                        ),
                      ],
                    ),
                    if (_draft.gender != null) ...[
                      const SizedBox(height: 18),
                      _Question(
                        no: 'A2.2',
                        label: 'Berapa usia anda?',
                        children: [
                          V2SelectCard<String>(
                            value: '35_45',
                            groupValue: _draft.ageBucket,
                            label: '35–45 tahun',
                            onChanged: (v) => setState(() => _draft.ageBucket = v),
                          ),
                          const SizedBox(height: 8),
                          V2SelectCard<String>(
                            value: '46_60',
                            groupValue: _draft.ageBucket,
                            label: '46–60 tahun',
                            onChanged: (v) => setState(() => _draft.ageBucket = v),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // Q3 — primary goal (hanya kalau ada kondisi medis)
                  if (showQ3) ...[
                    const SizedBox(height: 28),
                    _Question(
                      no: 'A3',
                      label: 'Apa yang paling ingin anda capai?',
                      description: 'Membantu kami prioritaskan fokus program.',
                      children: [
                        V2SelectCard<String>(
                          value: 'control_medical',
                          groupValue: _draft.primaryGoal,
                          label: 'Mengontrol kondisi medis saya',
                          onChanged: (v) => setState(() => _draft.primaryGoal = v),
                        ),
                        const SizedBox(height: 8),
                        V2SelectCard<String>(
                          value: 'hormonal_feminine',
                          groupValue: _draft.primaryGoal,
                          label: 'Menyeimbangkan hormon dan feminitas saya',
                          onChanged: (v) => setState(() => _draft.primaryGoal = v),
                        ),
                        const SizedBox(height: 8),
                        V2SelectCard<String>(
                          value: 'stamina_masculine',
                          groupValue: _draft.primaryGoal,
                          label: 'Meningkatkan stamina dan performa fisik pria',
                          onChanged: (v) => setState(() => _draft.primaryGoal = v),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
            V2BottomCta(
              label: 'Lanjut ke Phase B  →',
              onPressed: _canContinue ? _onContinue : null,
              hint: _canContinue ? null : 'Lengkapi pertanyaan untuk lanjut.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  final List<Widget> children;

  const _Question({
    required this.no,
    required this.label,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              no,
              style: SfTypography.label(
                fontSize: 11,
                color: kSfWarmGoldDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SfTypography.subheadline(
                      fontSize: 16, color: kSfCharcoal,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: SfTypography.body(
                        fontSize: 12.5,
                        color: kSfCharcoal.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool enabled;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SfTypography.label(
            fontSize: 11,
            color: kSfCharcoal.withOpacity(0.6),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : kSfIceBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null ? kSfWarmGold : kSfCharcoal.withOpacity(0.15),
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: SfTypography.body(
                      fontSize: 14,
                      color: value != null
                          ? kSfCharcoal
                          : kSfCharcoal.withOpacity(0.45),
                      weight: value != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kSfCharcoal.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
