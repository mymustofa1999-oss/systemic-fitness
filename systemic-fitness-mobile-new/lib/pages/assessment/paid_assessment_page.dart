import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/online_models/AssessmentModels.dart';
import 'package:workout/pages/assessment/widgets/assessment_widgets.dart';

/// 13-step wizard for the Paid Basic Assessment.
///
/// Sleep (6) + Movement (3) + Lab values (3 numeric + 1 medications)
/// + Review. Submit posts to /assessments/paid (status `submitted`,
/// trainer review happens server-side via PATCH /:id/review).
class PaidAssessmentPage extends StatefulWidget {
  const PaidAssessmentPage({super.key});

  @override
  State<PaidAssessmentPage> createState() => _PaidAssessmentPageState();
}

class _PaidAssessmentPageState extends State<PaidAssessmentPage> {
  final PageController _pageController = PageController();
  int _position = 0;
  bool _submitting = false;
  bool _prefilled = false;

  final SleepInputModel _sleep = SleepInputModel();
  final MovementInputModel _movement = MovementInputModel();
  final MetabolicInputModel _metabolic = MetabolicInputModel();

  final TextEditingController _hba1cCtrl = TextEditingController(text: '5.5');
  final TextEditingController _ldlCtrl = TextEditingController(text: '100');
  final TextEditingController _trigCtrl = TextEditingController(text: '140');
  final TextEditingController _medsCtrl = TextEditingController();

  ScaffoldMessengerState? _messenger;

  // 6 sleep + 3 movement + 4 lab + 1 review
  static const int _totalSteps = 14;
  static const int _firstLabIndex = 9; // index of HbA1c step
  static const int _reviewIndex = 13;

  @override
  void initState() {
    super.initState();
    _prefillFromLatestFree();
  }

  /// Fetch the user's most recent free assessment and pre-fill
  /// Sleep + Movement inputs so the user only needs to enter the
  /// metabolic lab values during upgrade. Silently no-ops when the
  /// user has no prior free assessment (404) or the network fails.
  Future<void> _prefillFromLatestFree() async {
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.assessmentLatest,
        queryParams: {'tier': 'free'},
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) return;

      final sleepJson = data['sleep'];
      final movementJson = data['movement'];
      if (sleepJson is Map<String, dynamic>) {
        final s = SleepInputModel.fromJson(sleepJson);
        _sleep
          ..durationHours = s.durationHours
          ..consistency = s.consistency
          ..latencyMinutes = s.latencyMinutes
          ..morningReadiness = s.morningReadiness
          ..wakeFrequency = s.wakeFrequency
          ..preSleepHabit = s.preSleepHabit;
      }
      if (movementJson is Map<String, dynamic>) {
        final m = MovementInputModel.fromJson(movementJson);
        _movement
          ..squat = m.squat
          ..hipHinge = m.hipHinge
          ..overhead = m.overhead;
      }

      if (!mounted) return;
      setState(() => _prefilled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 4),
          content: const Text(
            'Jawaban Sleep & Movement sudah diisi otomatis dari '
            'free assessment kamu. Edit kalau ada perubahan, atau '
            'langsung loncat ke step Lab Values.',
          ),
          action: SnackBarAction(
            label: 'Ke Lab',
            textColor: Colors.amberAccent,
            onPressed: () {
              if (!mounted) return;
              _goTo(_firstLabIndex);
            },
          ),
        ),
      );
    } on ApiException catch (e) {
      // 404 = user has no prior free assessment — completely fine.
      if (e.statusCode != 404) {
        debugPrint('[PaidAssessment] prefill failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('[PaidAssessment] prefill error: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _messenger?.hideCurrentSnackBar();
    _hba1cCtrl.dispose();
    _ldlCtrl.dispose();
    _trigCtrl.dispose();
    _medsCtrl.dispose();
    super.dispose();
  }

  void _goTo(int target) {
    if (target < 0 || target >= _totalSteps) return;
    setState(() => _position = target);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    // When leaving the lab steps, sync the controllers into the model
    // so the review step can show the up-to-date values.
    if (_position >= _firstLabIndex && _position < _reviewIndex) {
      _syncMetabolicFromControllers();
      // Validate the just-edited numeric step before advancing.
      if (!_validateLabStep(_position)) return;
    }
    if (_position < _totalSteps - 1) {
      _goTo(_position + 1);
    } else {
      _submit();
    }
  }

  bool _validateLabStep(int step) {
    String? raw;
    String label;
    switch (step) {
      case 9:
        raw = _hba1cCtrl.text;
        label = 'HbA1c';
        break;
      case 10:
        raw = _ldlCtrl.text;
        label = 'LDL';
        break;
      case 11:
        raw = _trigCtrl.text;
        label = 'Trigliserida';
        break;
      default:
        return true;
    }
    final n = double.tryParse(raw.trim());
    if (n == null || n <= 0) {
      Fluttertoast.showToast(
        msg: '$label harus diisi angka positif',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
  }

  void _syncMetabolicFromControllers() {
    _metabolic.hbA1c = double.tryParse(_hba1cCtrl.text.trim()) ?? _metabolic.hbA1c;
    _metabolic.ldl = double.tryParse(_ldlCtrl.text.trim()) ?? _metabolic.ldl;
    _metabolic.triglyceride = double.tryParse(_trigCtrl.text.trim()) ?? _metabolic.triglyceride;
    _metabolic.medications = _medsCtrl.text.trim().isEmpty
        ? const []
        : _medsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void _back() {
    if (_position == 0) {
      context.pop();
      return;
    }
    _goTo(_position - 1);
  }

  Future<void> _submit() async {
    _syncMetabolicFromControllers();
    setState(() => _submitting = true);
    try {
      final response = await ApiService.postWithRetry(
        ApiConfig.assessmentPaid,
        body: {
          'sleep': _sleep.toJson(),
          'movement': _movement.toJson(),
          'metabolic': _metabolic.toJson(),
        },
      );
      final data = response['data'];
      if (data == null) throw Exception('Empty response');
      final result = AssessmentResultModel.fromJson(data as Map<String, dynamic>);
      await PrefData.setHasCompletedAssessment(true);
      if (mounted) {
        context.pushReplacement('/assessment/result/${result.id}');
      }
    } on ApiException catch (e) {
      String msg = e.message;
      if (e.errors != null && e.errors!.isNotEmpty) {
        msg = e.errors!.join('\n');
      }
      Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red);
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Connection error. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _position == _totalSteps - 1;
    return Scaffold(
      backgroundColor: bgDarkWhite,
      appBar: AppBar(
        backgroundColor: bgDarkWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _back,
        ),
        title: ConstantWidget.getCustomText(
          'Paid Assessment',
          Colors.black,
          1,
          TextAlign.center,
          FontWeight.w600,
          18,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            StepProgressBar(total: _totalSteps, current: _position),
            if (_prefilled && _position < _firstLabIndex)
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: ConstantWidget.getScreenPercentSize(context, 4),
                  vertical: 6,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pre-filled dari free assessment kamu',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _goTo(_firstLabIndex),
                      child: const Text(
                        'Skip ke Lab →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _position = i),
                children: _buildSteps(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ConstantWidget.getScreenPercentSize(context, 4),
              ),
              child: ConstantWidget.getButtonWidget(
                context,
                _submitting
                    ? 'Mengirim...'
                    : (isLast ? 'Submit Assessment' : 'Lanjut'),
                accentColor,
                () {
                  if (_submitting) return;
                  _next();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    return [
      // ── Sleep (steps 0-5) ────────────────────────────────────
      DurationStep(
        value: _sleep.durationHours,
        onChanged: (v) => setState(() => _sleep.durationHours = v),
      ),
      OptionsStep(
        title: 'Konsistensi tidur',
        subtitle: 'Seberapa konsisten jam tidur dan bangun kamu?',
        options: const [
          AssessmentOption('Sangat tidak teratur', 1),
          AssessmentOption('Kadang berubah', 2),
          AssessmentOption('Teratur setiap hari', 3),
        ],
        value: _sleep.consistency,
        onChanged: (v) => setState(() => _sleep.consistency = v),
      ),
      OptionsStep(
        title: 'Sleep latency',
        subtitle: 'Berapa lama biasanya kamu butuh untuk tertidur?',
        options: const [
          AssessmentOption('< 15 menit', 10),
          AssessmentOption('15-30 menit', 25),
          AssessmentOption('> 45 menit', 60),
        ],
        value: _sleep.latencyMinutes,
        onChanged: (v) => setState(() => _sleep.latencyMinutes = v),
      ),
      OptionsStep(
        title: 'Morning readiness',
        subtitle: 'Bagaimana rasanya saat kamu bangun pagi?',
        options: const [
          AssessmentOption('Lelah / pusing', 1),
          AssessmentOption('Biasa saja', 2),
          AssessmentOption('Segar & bertenaga', 3),
        ],
        value: _sleep.morningReadiness,
        onChanged: (v) => setState(() => _sleep.morningReadiness = v),
      ),
      OptionsStep(
        title: 'Wake frequency',
        subtitle: 'Berapa kali kamu terbangun di tengah malam?',
        options: const [
          AssessmentOption('Tidak pernah', 0),
          AssessmentOption('1-2 kali', 2),
          AssessmentOption('Lebih dari 2x', 4),
        ],
        value: _sleep.wakeFrequency,
        onChanged: (v) => setState(() => _sleep.wakeFrequency = v),
      ),
      OptionsStep(
        title: 'Kebiasaan sebelum tidur',
        subtitle: 'Apa yang biasanya kamu lakukan sebelum tidur?',
        options: const [
          AssessmentOption('Gadget / makan berat / pikiran sibuk', 1),
          AssessmentOption('Campuran', 2),
          AssessmentOption('Rutinitas relaksasi', 3),
        ],
        value: _sleep.preSleepHabit,
        onChanged: (v) => setState(() => _sleep.preSleepHabit = v),
      ),

      // ── Movement (steps 6-8) ─────────────────────────────────
      OptionsStep(
        title: 'Bodyweight Squat',
        subtitle: 'Bagaimana hasil squat tanpa beban kamu?',
        options: const [
          AssessmentOption('Tidak mampu / nyeri', 1),
          AssessmentOption('Bisa, tapi ada kompensasi', 2),
          AssessmentOption('Mampu squat penuh', 3),
        ],
        value: _movement.squat,
        onChanged: (v) => setState(() => _movement.squat = v),
      ),
      OptionsStep(
        title: 'Hip Hinge',
        subtitle: 'Bagaimana saat membungkuk dengan punggung lurus?',
        options: const [
          AssessmentOption('Punggung melengkung', 1),
          AssessmentOption('Hamstring kaku', 2),
          AssessmentOption('Punggung netral lurus', 3),
        ],
        value: _movement.hipHinge,
        onChanged: (v) => setState(() => _movement.hipHinge = v),
      ),
      OptionsStep(
        title: 'Overhead Reach',
        subtitle: 'Saat kedua tangan diangkat lurus ke atas?',
        options: const [
          AssessmentOption('Bahu shrug / tertahan di depan', 1),
          AssessmentOption('Bisa lurus dengan usaha', 2),
          AssessmentOption('Lurus di samping telinga', 3),
        ],
        value: _movement.overhead,
        onChanged: (v) => setState(() => _movement.overhead = v),
      ),

      // ── Lab values (steps 9-12) ──────────────────────────────
      LabValueStep(
        title: 'HbA1c',
        subtitle: 'Hasil tes darah HbA1c terbaru kamu',
        unit: '%',
        helperTitle: 'Apa itu HbA1c?',
        helperBody:
            'HbA1c (Hemoglobin A1c) menunjukkan rata-rata kadar gula darah '
            'selama 2-3 bulan terakhir.\n\n'
            '• Normal: < 5.7%\n'
            '• Pre-diabetes: 5.7% – 6.4%\n'
            '• Diabetes: ≥ 6.5%\n\n'
            'Nilai bisa kamu lihat di hasil cek lab darah lengkap.',
        controller: _hba1cCtrl,
      ),
      LabValueStep(
        title: 'LDL Cholesterol',
        subtitle: 'Hasil tes LDL ("kolesterol jahat") terbaru',
        unit: 'mg/dL',
        helperTitle: 'Apa itu LDL?',
        helperBody:
            'LDL (Low-Density Lipoprotein) adalah kolesterol "jahat" yang '
            'kalau berlebihan bisa menempel di dinding pembuluh darah.\n\n'
            '• Optimal: < 100 mg/dL\n'
            '• Borderline: 100 – 129 mg/dL\n'
            '• Tinggi: ≥ 130 mg/dL',
        controller: _ldlCtrl,
      ),
      LabValueStep(
        title: 'Trigliserida',
        subtitle: 'Hasil tes trigliserida terbaru',
        unit: 'mg/dL',
        helperTitle: 'Apa itu Trigliserida?',
        helperBody:
            'Trigliserida adalah jenis lemak utama dalam darah. Kadar yang '
            'tinggi terkait dengan risiko penyakit jantung dan sindrom metabolik.\n\n'
            '• Normal: < 150 mg/dL\n'
            '• Borderline: 150 – 199 mg/dL\n'
            '• Tinggi: ≥ 200 mg/dL',
        controller: _trigCtrl,
      ),
      MedicationsStep(controller: _medsCtrl),

      // ── Review (step 13) ─────────────────────────────────────
      ReviewStep(
        sleep: _sleep,
        movement: _movement,
        metabolic: _liveMetabolicForReview(),
        onEdit: () => _goTo(0),
      ),
    ];
  }

  /// Returns a snapshot of the metabolic model with the latest values
  /// from the text controllers, so the review step is always fresh
  /// even if the user jumps around the wizard.
  MetabolicInputModel _liveMetabolicForReview() {
    _syncMetabolicFromControllers();
    return _metabolic;
  }
}
