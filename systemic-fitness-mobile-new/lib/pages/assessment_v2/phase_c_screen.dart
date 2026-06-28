import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../data/api_config.dart';
import '../../data/api_service.dart';
import '../../online_models/AssessmentV2Models.dart';
import '../../util/sf_typography.dart';
import 'assessment_v2_draft.dart';
import 'widgets/phase_progress_indicator.dart';

/// Phase C — 7 pertanyaan nutrisi. C4-C6 multi-select. Submit ke API
/// di akhir (POST /api/v2/assessments dengan phase_a + phase_b + phase_c).
class PhaseCScreen extends StatefulWidget {
  const PhaseCScreen({super.key});

  @override
  State<PhaseCScreen> createState() => _PhaseCScreenState();
}

class _PhaseCScreenState extends State<PhaseCScreen> {
  late PhaseCInput _draft;
  final Set<String> _answered = {};
  final TextEditingController _restrictionNote = TextEditingController();
  final TextEditingController _supplementNote = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _draft = AssessmentV2Draft.instance.phaseC ?? PhaseCInput();
    _restrictionNote.text = _draft.restrictionNote ?? '';
    _supplementNote.text = _draft.supplementNote ?? '';
  }

  @override
  void dispose() {
    _restrictionNote.dispose();
    _supplementNote.dispose();
    super.dispose();
  }

  bool get _canContinue {
    // Wajib: C1, C2, C3, C7. C4/C5/C6 multi-select boleh kosong (None).
    return _answered.containsAll({'C1', 'C2', 'C3', 'C7'});
  }

  void _setSingle(String key, int value, void Function(int) apply) {
    setState(() {
      _answered.add(key);
      apply(value);
    });
  }

  void _toggleMulti(List<String> list, String key) {
    setState(() {
      if (list.contains(key)) {
        list.remove(key);
      } else {
        list.add(key);
      }
    });
  }

  Future<void> _submit() async {
    if (!_canContinue) {
      Fluttertoast.showToast(
        msg: 'Lengkapi semua pertanyaan wajib (C1, C2, C3, C7).',
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      _draft.restrictionNote = _restrictionNote.text.trim();
      _draft.supplementNote = _supplementNote.text.trim();
      AssessmentV2Draft.instance.phaseC = _draft;

      final draft = AssessmentV2Draft.instance;
      final body = <String, dynamic>{
        'phase_a': draft.phaseA.toJson(),
        if (draft.phaseB != null) 'phase_b': draft.phaseB!.toJson(),
        'phase_c': draft.phaseC!.toJson(),
      };

      final res = await ApiService.post(
        ApiConfig.assessmentV2,
        body: body,
      );
      final data = res['data'];
      if (data == null) {
        throw Exception('Empty response');
      }
      final result = AssessmentV2Result.fromJson(data as Map<String, dynamic>);
      if (!mounted) return;
      // Replace stack — flow assessment selesai, user shouldn't tap-back to Phase C.
      context.go('/assessment-v2/result/${result.id}');
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal mengirim asesmen. Coba lagi.',
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
    final wajibAnswered =
        ['C1', 'C2', 'C3', 'C7'].where((k) => _answered.contains(k)).length;

    return Scaffold(
      backgroundColor: kSfWarmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PhaseHeader(
              currentPhase: 2,
              title: 'Pola Makan & Gizi',
              subProgress: '$wajibAnswered/4 wajib',
              onBack: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _SingleC(
                    no: 'C1',
                    label: 'Bagaimana gambaran pola makan anda sehari-hari?',
                    options: const [
                      _OptC(1, 'Makan besar 3 kali sehari, jarang snack'),
                      _OptC(2, 'Makan 4–5 kali dalam porsi lebih kecil'),
                      _OptC(3, 'Sering skip makan — tidak teratur'),
                      _OptC(4, 'Intermittent fasting (mis. 16/8)'),
                      _OptC(5, 'Tidak ada pola tetap'),
                    ],
                    selected: _answered.contains('C1') ? _draft.mealPattern : null,
                    onChanged: (v) => _setSingle('C1', v, (x) => _draft.mealPattern = x),
                  ),
                  const SizedBox(height: 24),
                  _SingleC(
                    no: 'C2',
                    label: 'Apa yang paling sering ada di piring anda?',
                    options: const [
                      _OptC(1, 'Nasi / karbohidrat sebagai porsi terbesar'),
                      _OptC(2, 'Protein (ayam, ikan, telur, daging) sebagai fokus'),
                      _OptC(3, 'Sayur dan buah mendominasi'),
                      _OptC(4, 'Campuran seimbang antara karbo, protein, dan sayur'),
                      _OptC(5, 'Makanan olahan / fast food cukup sering'),
                    ],
                    selected: _answered.contains('C2') ? _draft.foodDominance : null,
                    onChanged: (v) => _setSingle('C2', v, (x) => _draft.foodDominance = x),
                  ),
                  const SizedBox(height: 24),
                  _SingleC(
                    no: 'C3',
                    label: 'Berapa gelas air putih per hari?',
                    description: '1 gelas = 250 ml.',
                    options: const [
                      _OptC(1, 'Kurang dari 4 gelas — sangat kurang'),
                      _OptC(2, '4–6 gelas — kurang'),
                      _OptC(3, '7–8 gelas — cukup'),
                      _OptC(4, 'Lebih dari 8 gelas — baik'),
                    ],
                    selected: _answered.contains('C3') ? _draft.hydration : null,
                    onChanged: (v) => _setSingle('C3', v, (x) => _draft.hydration = x),
                  ),
                  const SizedBox(height: 24),
                  _MultiC(
                    no: 'C4',
                    label: 'Pilih semua yang sering dalam konsumsi harian anda.',
                    description: 'Boleh pilih lebih dari satu.',
                    options: const [
                      _OptStr('coffee', 'Kopi (1+ cangkir per hari)'),
                      _OptStr('sweet_drinks', 'Teh manis / minuman manis lain'),
                      _OptStr('soda_energy', 'Minuman bersoda / energi drink'),
                      _OptStr('alcohol', 'Alkohol'),
                      _OptStr('fried', 'Makanan digoreng / berminyak'),
                      _OptStr('high_salt', 'Makanan tinggi garam'),
                      _OptStr('organ_meat', 'Jeroan'),
                      _OptStr('seafood', 'Seafood (udang, cumi, kerang)'),
                      _OptStr('dairy', 'Susu & produk susu'),
                      _OptStr('fermented', 'Makanan fermentasi (tempe, tape, kimchi)'),
                    ],
                    selected: _draft.routineFoods,
                    onToggle: (s) => _toggleMulti(_draft.routineFoods, s),
                  ),
                  const SizedBox(height: 24),
                  _MultiC(
                    no: 'C5',
                    label: 'Apakah anda memiliki pantangan atau alergi makanan?',
                    description: 'Jadi filter untuk semua rekomendasi gizi.',
                    options: const [
                      _OptStr('none', 'Tidak ada'),
                      _OptStr('specific_allergy', 'Alergi spesifik'),
                      _OptStr('religious', 'Pantangan agama / keyakinan (halal, vegan, dll)'),
                      _OptStr('lactose', 'Intoleransi laktosa'),
                      _OptStr('gluten', 'Intoleransi / sensitivitas gluten'),
                      _OptStr('other', 'Pantangan lainnya'),
                    ],
                    selected: _draft.restrictions,
                    onToggle: (s) => _toggleMulti(_draft.restrictions, s),
                    noteController: _restrictionNote,
                    notePlaceholder: 'Tuliskan detail alergi / pantangan (opsional)',
                  ),
                  const SizedBox(height: 24),
                  _MultiC(
                    no: 'C6',
                    label: 'Suplemen / obat yang sedang anda konsumsi',
                    description: 'Memberi konteks tambahan untuk Health Consultant.',
                    options: const [
                      _OptStr('none', 'Tidak ada'),
                      _OptStr('multivitamin', 'Multivitamin umum'),
                      _OptStr('vitamin_d', 'Vitamin D'),
                      _OptStr('omega_3', 'Omega-3 / Fish oil'),
                      _OptStr('protein', 'Suplemen protein (whey, plant-based)'),
                      _OptStr('other', 'Suplemen spesifik lainnya'),
                      _OptStr('rx_metabolic', 'Obat dokter yang mempengaruhi metabolisme'),
                    ],
                    selected: _draft.supplements,
                    onToggle: (s) => _toggleMulti(_draft.supplements, s),
                    noteController: _supplementNote,
                    notePlaceholder: 'Sebutkan nama suplemen / obat (opsional)',
                  ),
                  const SizedBox(height: 24),
                  _SingleCStr(
                    no: 'C7',
                    label: 'Apa yang paling ingin anda perbaiki dari pola makan?',
                    options: const [
                      _OptStr('blood_sugar', 'Mengontrol gula darah dan metabolisme'),
                      _OptStr('anti_inflammation', 'Mengurangi peradangan, bloating, ketidaknyamanan pencernaan'),
                      _OptStr('energy_vitality', 'Meningkatkan energi dan vitalitas'),
                      _OptStr('hormonal_balance', 'Mendukung keseimbangan hormonal'),
                      _OptStr('weight', 'Menjaga berat badan yang sehat'),
                      _OptStr('muscle_recovery', 'Mendukung performa, pemulihan otot, kebugaran'),
                      _OptStr('organ_health', 'Mendukung kesehatan organ spesifik (ginjal, jantung)'),
                    ],
                    selected: _answered.contains('C7') ? _draft.nutritionGoal : null,
                    onChanged: (v) {
                      setState(() {
                        _answered.add('C7');
                        _draft.nutritionGoal = v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            V2BottomCta(
              label: _submitting ? 'Menyimpan…' : 'Selesai & Lihat Hasil',
              onPressed: _canContinue && !_submitting ? _submit : null,
              loading: _submitting,
              hint: _canContinue
                  ? null
                  : 'Lengkapi pertanyaan wajib (C1, C2, C3, C7) untuk lanjut.',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subcomponents ───────────────────────────────────────────────

class _OptC {
  final int value;
  final String label;
  const _OptC(this.value, this.label);
}

class _OptStr {
  final String value;
  final String label;
  const _OptStr(this.value, this.label);
}

class _SingleC extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  final List<_OptC> options;
  final int? selected;
  final ValueChanged<int> onChanged;
  const _SingleC({
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
        _Header(no: no, label: label, description: description),
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

class _SingleCStr extends StatelessWidget {
  final String no;
  final String label;
  final List<_OptStr> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  const _SingleCStr({
    required this.no,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(no: no, label: label),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          V2SelectCard<String>(
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

class _MultiC extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  final List<_OptStr> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final TextEditingController? noteController;
  final String? notePlaceholder;
  const _MultiC({
    required this.no,
    required this.label,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.description,
    this.noteController,
    this.notePlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(no: no, label: label, description: description),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          V2MultiChip(
            label: options[i].label,
            selected: selected.contains(options[i].value),
            onTap: () => onToggle(options[i].value),
          ),
        ],
        if (noteController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: notePlaceholder,
              hintStyle: SfTypography.body(
                fontSize: 13,
                color: kSfCharcoal.withOpacity(0.4),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSfCharcoal.withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSfCharcoal.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kSfWarmGold, width: 1.5),
              ),
            ),
            style: SfTypography.body(fontSize: 13.5, color: kSfCharcoal),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String no;
  final String label;
  final String? description;
  const _Header({required this.no, required this.label, this.description});

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
