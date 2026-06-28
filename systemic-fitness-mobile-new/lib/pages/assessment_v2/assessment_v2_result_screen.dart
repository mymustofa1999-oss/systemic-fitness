import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../ColorCategory.dart';
import '../../data/api_config.dart';
import '../../data/api_service.dart';
import '../../online_models/AssessmentV2Models.dart';
import '../../online_models/ClinicalNoteModel.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';
import 'widgets/system_score_gauge.dart';

class AssessmentV2ResultScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentV2ResultScreen({super.key, required this.assessmentId});

  @override
  State<AssessmentV2ResultScreen> createState() =>
      _AssessmentV2ResultScreenState();
}

class _AssessmentV2ResultScreenState extends State<AssessmentV2ResultScreen> {
  bool _loading = true;
  String? _error;
  AssessmentV2Result? _result;
  List<ClinicalNoteModel> _publishedNotes = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.assessmentV2ById(widget.assessmentId),
      );
      final data = res['data'];
      if (data == null) throw Exception('Empty response');
      final assessment =
          AssessmentV2Result.fromJson(data as Map<String, dynamic>);

      // SF Phase 7e — fetch published clinical notes terkait asesmen ini.
      // Server-side ACL: client cuma boleh lihat note dengan
      // is_visible_to_client=true; only_published=true cukup sebagai
      // pengaman tambahan kalau JWT scope berubah.
      final notes = await _loadPublishedNotes(assessment.id);

      setState(() {
        _result = assessment;
        _publishedNotes = notes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat hasil asesmen.\n$e';
        _loading = false;
      });
    }
  }

  Future<List<ClinicalNoteModel>> _loadPublishedNotes(
    String assessmentId,
  ) async {
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.clinicalNotes,
        queryParams: {
          'assessment_id': assessmentId,
          'only_published': 'true',
        },
      );
      final list = res['data'] as List<dynamic>?;
      if (list == null) return const [];
      return list
          .map((e) => ClinicalNoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Catatan klinis bersifat opsional di view klien — fail silent.
      return const [];
    }
  }

  void _onDone() {
    AssessmentV2Draft.instance.reset();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kSfDeepNavy,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kSfWarmWhite,
        body: _loading
            ? const SafeArea(
                child: Center(
                  child: CircularProgressIndicator(color: kSfWarmGold),
                ),
              )
            : _error != null
                ? _buildError()
                : _buildResult(_result!),
      ),
    );
  }

  Widget _buildError() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: SfTypography.body(fontSize: 14, color: kSfCharcoal),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: kSfWarmGold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(AssessmentV2Result a) {
    return Column(
      children: [
        _Hero(result: a),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              // Phase A summary
              _SummaryCard(
                title: 'Profil Phase A',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RowField(
                      label: 'Program Type',
                      value: a.prettyProgramType,
                    ),
                    if (a.phaseA.classificationSlug != null) ...[
                      const SizedBox(height: 8),
                      _RowField(
                        label: 'Klasifikasi',
                        value: _prettyClass(a.phaseA.classificationSlug!),
                      ),
                    ],
                    if (a.phaseA.specificConditionSlug != null) ...[
                      const SizedBox(height: 8),
                      _RowField(
                        label: 'Kondisi spesifik',
                        value: a.phaseA.specificConditionSlug!,
                      ),
                    ],
                    if (a.phaseA.gender != null) ...[
                      const SizedBox(height: 8),
                      _RowField(
                        label: 'Gender / Usia',
                        value:
                            '${a.phaseA.gender == "women" ? "Wanita" : "Pria"} · ${a.phaseA.ageBucket?.replaceAll("_", "–")}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Chronobiology Window
              if (a.chronobiologyWindow != null)
                _ChronobiologyCard(window: a.chronobiologyWindow!),
              if (a.chronobiologyWindow != null) const SizedBox(height: 14),

              // Flags klinis
              if (a.flags.isNotEmpty)
                _FlagsCard(flags: a.flags),
              if (a.flags.isNotEmpty) const SizedBox(height: 14),

              // SF Phase 7e — Catatan dari Health Consultant (kalau sudah di-publish).
              if (_publishedNotes.isNotEmpty) ...[
                _ConsultantNotesCard(notes: _publishedNotes),
                const SizedBox(height: 14),
              ],

              Center(
                child: Text(
                  'Disubmit ${DateFormat('d MMM y · HH.mm', 'id').format(a.createdAt.toLocal())}',
                  style: SfTypography.body(
                    fontSize: 11.5,
                    color: kSfCharcoal.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        // CTA
        Padding(
          padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 14,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: kSfWarmGold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Selesai → Dashboard',
                style: SfTypography.ctaPrimary(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _prettyClass(String slug) {
    switch (slug) {
      case 'imun-inflamasi': return 'Imun & Inflamasi';
      case 'renal-uric': return 'Renal & Uric System';
      case 'cardiorespiratory': return 'Cardiorespiratory';
      case 'metabolic': return 'Metabolic';
      case 'musculoskeletal': return 'Musculoskeletal';
    }
    return slug;
  }
}

class _Hero extends StatelessWidget {
  final AssessmentV2Result result;
  const _Hero({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20, MediaQuery.of(context).padding.top + 12, 20, 22,
      ),
      decoration: const BoxDecoration(color: kSfDeepNavy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM SCORE',
            style: SfTypography.label(
              fontSize: 11, color: kSfWarmGold, letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sistem tubuh anda',
            style: SfTypography.headline(
              fontSize: 22, color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SystemScoreGauge(
                score: result.systemScore ?? 0,
                tier: result.scoreTier,
                size: 120,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    ScoreBreakdownBar(
                      label: 'Movement',
                      value: result.movementScore,
                      color: kSfWarmGold,
                    ),
                    const SizedBox(height: 10),
                    ScoreBreakdownBar(
                      label: 'Nutrition',
                      value: result.nutritionScore,
                      color: kSfSystemBlue,
                    ),
                    const SizedBox(height: 10),
                    ScoreBreakdownBar(
                      label: 'Rest',
                      value: result.restScore,
                      color: kSfDeepTeal,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.movementScore == null) ...[
            const SizedBox(height: 14),
            Text(
              'Movement Score akan terisi saat anda mulai sesi pertama.',
              style: SfTypography.body(
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.55),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SummaryCard({required this.title, required this.child});

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
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SfTypography.subheadline(fontSize: 15, color: kSfCharcoal),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RowField extends StatelessWidget {
  final String label;
  final String value;
  const _RowField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: SfTypography.body(
              fontSize: 12,
              color: kSfCharcoal.withOpacity(0.55),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: SfTypography.body(
              fontSize: 13,
              color: kSfCharcoal,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChronobiologyCard extends StatelessWidget {
  final ChronobiologyWindow window;
  const _ChronobiologyCard({required this.window});

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
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: kSfWarmGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Chronobiology Window',
                style: SfTypography.subheadline(fontSize: 15, color: kSfCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rekomendasi waktu sesi yang dipersonalisasi.',
            style: SfTypography.body(
              fontSize: 12, color: kSfCharcoal.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _WindowCell(
                  label: 'Ideal',
                  value: '${window.idealStart} – ${window.idealEnd}',
                  bg: const Color(0xFFFFF4D6),
                  fg: kSfWarmGoldDark,
                ),
              ),
              if (window.altStart != null && window.altStart!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _WindowCell(
                    label: 'Alternatif',
                    value: '${window.altStart} – ${window.altEnd}',
                    bg: const Color(0xFFE6F4EA),
                    fg: const Color(0xFF1F6B3A),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (window.avoid != null && window.avoid!.isNotEmpty)
                Expanded(
                  child: _WindowCell(
                    label: 'Hindari',
                    value: window.avoid!,
                    bg: const Color(0xFFFCE8E6),
                    fg: const Color(0xFFA32A22),
                  ),
                ),
              if (window.avoid != null) const SizedBox(width: 8),
              if (window.hardCap != null && window.hardCap!.isNotEmpty)
                Expanded(
                  child: _WindowCell(
                    label: 'Hard Cap',
                    value: window.hardCap!,
                    bg: const Color(0xFFEDEEF2),
                    fg: kSfMidnightBlue,
                  ),
                ),
            ],
          ),
          if (window.overrideReason != null && window.overrideReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kSfIceBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: kSfWarmGold, width: 3),
                ),
              ),
              child: Text(
                window.overrideReason!,
                style: SfTypography.body(
                  fontSize: 12,
                  color: kSfMidnightBlue,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WindowCell extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;
  const _WindowCell({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: SfTypography.label(
              fontSize: 9, color: fg.withOpacity(0.7), letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: SfTypography.data(
              fontSize: 13, color: fg, weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagsCard extends StatelessWidget {
  final List<String> flags;
  const _FlagsCard({required this.flags});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.amber.shade800, size: 18),
              const SizedBox(width: 8),
              Text(
                'Catatan untuk Konsultan',
                style: SfTypography.subheadline(
                  fontSize: 15, color: kSfCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...flags.map((f) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• ${_prettyFlag(f)}',
                  style: SfTypography.body(
                    fontSize: 12.5, color: kSfCharcoal,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  String _prettyFlag(String code) {
    switch (code) {
      case 'WAITLIST_LEVEL_0_3':
        return 'Akses program belum dibuka untuk kondisi mobilitas anda — masuk waitlist.';
      case 'REST_RECOVERY_ALERT':
        return 'Pola tidur kurang dari 6 jam dengan sering terbangun — pertimbangkan turunkan intensitas sesi.';
      case 'META_BLOOD_SUGAR_RISK':
        return 'Makan malam larut + sleep latency tinggi — sinyal gula darah spike.';
      case 'RENAL_HYDRATION_CRITICAL':
        return 'Hidrasi sangat kurang dengan kondisi ginjal/asam urat — flag kritis.';
    }
    return code;
  }
}

// ─── SF Phase 7e: Consultant Notes Card ─────────────────────────────

class _ConsultantNotesCard extends StatelessWidget {
  final List<ClinicalNoteModel> notes;
  const _ConsultantNotesCard({required this.notes});

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
        border: Border(
          left: BorderSide(color: kSfWarmGold, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  color: kSfWarmGold, size: 18),
              const SizedBox(width: 8),
              Text(
                notes.length == 1
                    ? 'Catatan dari Health Consultant'
                    : 'Catatan dari Health Consultant (${notes.length})',
                style: SfTypography.subheadline(
                  fontSize: 15,
                  color: kSfCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sudah ditinjau oleh tim klinis Systemic Fitness.',
            style: SfTypography.body(
              fontSize: 12,
              color: kSfCharcoal.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(notes.length, (i) {
            final n = notes[i];
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i == notes.length - 1 ? 0 : 12),
              child: _NoteEntry(note: n),
            );
          }),
        ],
      ),
    );
  }
}

class _NoteEntry extends StatelessWidget {
  final ClinicalNoteModel note;
  const _NoteEntry({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSfIceBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.title.isNotEmpty) ...[
            Text(
              note.title,
              style: SfTypography.subheadline(
                fontSize: 13.5,
                color: kSfCharcoal,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            note.content,
            style: SfTypography.body(
              fontSize: 13,
              color: kSfCharcoal,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 12, color: kSfCharcoal.withOpacity(0.5)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${note.consultantName ?? "Health Consultant"} · ${DateFormat('d MMM y', 'id').format(note.createdAt.toLocal())}',
                  style: SfTypography.body(
                    fontSize: 11,
                    color: kSfCharcoal.withOpacity(0.55),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
