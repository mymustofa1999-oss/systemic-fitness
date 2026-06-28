import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../online_models/AssessmentV2Models.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';
import 'widgets/phase_progress_indicator.dart';

/// Phase B — 10 pertanyaan tidur & aktivitas. Output: Rest Score +
/// Chronobiology Window. B1 pakai slider, B2-B10 single-select.
class PhaseBScreen extends StatefulWidget {
  const PhaseBScreen({super.key});

  @override
  State<PhaseBScreen> createState() => _PhaseBScreenState();
}

class _PhaseBScreenState extends State<PhaseBScreen> {
  late PhaseBInput _draft;
  // Track jawaban (semua int default 0 ambigu)
  final Set<String> _answered = {'B1'}; // B1 punya default 7.0 yang valid

  @override
  void initState() {
    super.initState();
    _draft = AssessmentV2Draft.instance.phaseB ?? PhaseBInput();
  }

  bool get _allAnswered => _answered.length >= 10;

  void _set(String key, VoidCallback apply) {
    setState(() {
      _answered.add(key);
      apply();
    });
  }

  void _onContinue() {
    AssessmentV2Draft.instance.phaseB = _draft;
    context.push(AppRoutes.assessmentV2PhaseC);
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
              currentPhase: 1,
              title: 'Pola Tidur & Aktivitas',
              subProgress: '${_answered.length}/10',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _SliderQuestion(
                    no: 'B1',
                    label: 'Rata-rata berapa jam anda tidur per malam?',
                    value: _draft.durationHours,
                    onChanged: (v) {
                      setState(() {
                        _answered.add('B1');
                        _draft.durationHours = v;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B2',
                    label: 'Seberapa konsisten jam tidur dan bangun anda?',
                    options: const [
                      _Opt(1, 'Sangat tidak teratur — berbeda lebih dari 2 jam setiap hari'),
                      _Opt(2, 'Kadang berubah — berbeda sekitar 1–2 jam'),
                      _Opt(3, 'Teratur setiap hari — hampir selalu di jam yang sama'),
                    ],
                    selected: _answered.contains('B2') ? _draft.consistency : null,
                    onChanged: (v) => _set('B2', () => _draft.consistency = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B3',
                    label: 'Berapa lama biasanya anda butuh untuk tertidur?',
                    description: 'Indikator kortisol & gula darah malam.',
                    options: const [
                      _Opt(1, 'Kurang dari 15 menit — langsung mengantuk (optimal)'),
                      _Opt(2, '15–30 menit — cukup normal'),
                      _Opt(3, '30–45 menit — agak sulit tidur'),
                      _Opt(4, 'Lebih dari 45 menit — sulit sekali tidur'),
                    ],
                    selected: _answered.contains('B3') ? _draft.sleepLatency : null,
                    onChanged: (v) => _set('B3', () => _draft.sleepLatency = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B4',
                    label: 'Bagaimana perasaan anda saat bangun pagi?',
                    options: const [
                      _Opt(1, 'Lelah / pusing — tidak terasa sudah tidur'),
                      _Opt(2, 'Biasa saja — butuh beberapa menit untuk segar'),
                      _Opt(3, 'Segar & langsung bertenaga'),
                    ],
                    selected: _answered.contains('B4') ? _draft.morningReadiness : null,
                    onChanged: (v) => _set('B4', () => _draft.morningReadiness = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B5',
                    label: 'Seberapa sering anda terbangun di tengah malam?',
                    description: 'Indikator hipertensi atau fluktuasi gula darah.',
                    options: const [
                      _Opt(1, 'Tidak pernah — tidur nyenyak sampai pagi'),
                      _Opt(2, '1–2 kali — bisa tidur lagi dengan mudah'),
                      _Opt(3, '3+ kali — sering terbangun'),
                      _Opt(4, 'Sering terbangun dan sulit tidur lagi'),
                    ],
                    selected: _answered.contains('B5') ? _draft.wakeFrequency : null,
                    onChanged: (v) => _set('B5', () => _draft.wakeFrequency = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B6',
                    label: 'Apa yang biasanya anda lakukan 1 jam sebelum tidur?',
                    options: const [
                      _Opt(1, 'Gadget aktif / kerja / makan berat / pikiran sibuk'),
                      _Opt(2, 'Campuran — kadang santai, kadang masih aktif'),
                      _Opt(3, 'Rutinitas relaksasi — baca, meditasi, stretching ringan'),
                    ],
                    selected: _answered.contains('B6') ? _draft.preSleepHabit : null,
                    onChanged: (v) => _set('B6', () => _draft.preSleepHabit = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B7',
                    label: 'Biasanya anda tidur jam berapa malam?',
                    description: 'Dasar perhitungan 5-Hour Recovery Window.',
                    options: const [
                      _Opt(1, 'Sebelum jam 21.00'),
                      _Opt(2, 'Jam 21.00–22.00'),
                      _Opt(3, 'Jam 22.00–23.00'),
                      _Opt(4, 'Jam 23.00–00.00'),
                      _Opt(5, 'Setelah jam 00.00'),
                    ],
                    selected: _answered.contains('B7') ? _draft.bedtimeBucket : null,
                    onChanged: (v) => _set('B7', () => _draft.bedtimeBucket = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B8',
                    label: 'Biasanya anda bangun jam berapa?',
                    options: const [
                      _Opt(1, 'Sebelum jam 05.00'),
                      _Opt(2, 'Jam 05.00–06.00'),
                      _Opt(3, 'Jam 06.00–07.00'),
                      _Opt(4, 'Jam 07.00–08.00'),
                      _Opt(5, 'Setelah jam 08.00'),
                    ],
                    selected: _answered.contains('B8') ? _draft.wakeTimeBucket : null,
                    onChanged: (v) => _set('B8', () => _draft.wakeTimeBucket = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQActivityProfile(
                    selected: _answered.contains('B9') ? _draft.activityProfile : null,
                    onChanged: (v) => _set('B9', () => _draft.activityProfile = v),
                  ),
                  const SizedBox(height: 24),
                  _SingleQ(
                    no: 'B10',
                    label: 'Biasanya anda makan malam jam berapa?',
                    description: 'Makan malam larut + sleep latency tinggi = sinyal gula darah spike.',
                    options: const [
                      _Opt(1, 'Sebelum jam 18.00'),
                      _Opt(2, 'Jam 18.00–19.00'),
                      _Opt(3, 'Jam 19.00–20.00'),
                      _Opt(4, 'Setelah jam 20.00'),
                      _Opt(5, 'Tidak menentu / sering skip'),
                    ],
                    selected: _answered.contains('B10') ? _draft.dinnerTime : null,
                    onChanged: (v) => _set('B10', () => _draft.dinnerTime = v),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            V2BottomCta(
              label: 'Lanjut ke Phase C  →',
              onPressed: _allAnswered ? _onContinue : null,
              hint: _allAnswered
                  ? null
                  : 'Lengkapi ${10 - _answered.length} pertanyaan lagi.',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subcomponents ───────────────────────────────────────────────

class _Opt {
  final int value;
  final String label;
  const _Opt(this.value, this.label);
}

class _SingleQ extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  final List<_Opt> options;
  final int? selected;
  final ValueChanged<int> onChanged;

  const _SingleQ({
    required this.no,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QHeader(no: no, label: label, description: description),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          V2SelectCard<int>(
            value: options[i].value,
            groupValue: selected,
            label: options[i].label,
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }
}

class _SingleQActivityProfile extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _SingleQActivityProfile({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QHeader(
          no: 'B9',
          label: 'Mana yang paling menggambarkan rutinitas harian anda?',
          description: 'Menentukan window waktu yang realistis untuk sesi.',
        ),
        const SizedBox(height: 12),
        V2SelectCard<String>(
          value: 'executive', groupValue: selected,
          label: 'Pekerja eksekutif / kantoran',
          hint: 'Jadwal rutin pagi sampai sore.',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<String>(
          value: 'creative', groupValue: selected,
          label: 'Pekerja kreatif / freelancer',
          hint: 'Jam kerja tidak menentu, sering aktif malam.',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<String>(
          value: 'traveller', groupValue: selected,
          label: 'Frequent traveller',
          hint: 'Sering beda zona waktu — anchor sore lokal.',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<String>(
          value: 'homemaker', groupValue: selected,
          label: 'Ibu rumah tangga',
          hint: 'Aktif pagi, fleksibel siang.',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<String>(
          value: 'shift_worker', groupValue: selected,
          label: 'Pekerja shift',
          hint: 'Window malam 19:00–20:30 (hard cap 21:00).',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        V2SelectCard<String>(
          value: 'mixed', groupValue: selected,
          label: 'Campuran / tidak menentu',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _QHeader extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  const _QHeader({required this.no, required this.label, this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          no,
          style: SfTypography.label(
            fontSize: 11, color: kSfWarmGoldDark, letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SfTypography.subheadline(fontSize: 16, color: kSfCharcoal),
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
    );
  }
}

class _SliderQuestion extends StatelessWidget {
  final String no;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderQuestion({
    required this.no,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QHeader(no: no, label: label),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kSfWarmGold.withOpacity(0.4), width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: SfTypography.data(
                      fontSize: 30, color: kSfWarmGoldDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'jam',
                      style: SfTypography.body(
                        fontSize: 14,
                        color: kSfCharcoal.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: kSfWarmGold,
                  inactiveTrackColor: kSfCharcoal.withOpacity(0.15),
                  thumbColor: kSfWarmGold,
                  overlayColor: kSfWarmGold.withOpacity(0.2),
                  valueIndicatorColor: kSfMidnightBlue,
                  trackHeight: 4,
                ),
                child: Slider(
                  min: 4.0,
                  max: 10.0,
                  divisions: 12,
                  value: value,
                  label: '${value.toStringAsFixed(1)} jam',
                  onChanged: onChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('4 jam', style: SfTypography.label(
                      fontSize: 10, color: kSfCharcoal.withOpacity(0.5),
                    )),
                    Text('7–8 optimal', style: SfTypography.label(
                      fontSize: 10, color: kSfDeepTeal,
                    )),
                    Text('10 jam', style: SfTypography.label(
                      fontSize: 10, color: kSfCharcoal.withOpacity(0.5),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
