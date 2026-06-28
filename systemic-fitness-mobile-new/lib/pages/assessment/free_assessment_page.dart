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

/// 10-step wizard for the Free Basic Assessment.
///
/// Sleep (6 questions) + Movement (3 questions) + Review.
/// On submit posts to /assessments/free and navigates to result.
class FreeAssessmentPage extends StatefulWidget {
  const FreeAssessmentPage({super.key});

  @override
  State<FreeAssessmentPage> createState() => _FreeAssessmentPageState();
}

class _FreeAssessmentPageState extends State<FreeAssessmentPage> {
  final PageController _pageController = PageController();
  int _position = 0;
  bool _submitting = false;

  final SleepInputModel _sleep = SleepInputModel();
  final MovementInputModel _movement = MovementInputModel();

  static const int _totalSteps = 10; // 6 sleep + 3 movement + 1 review

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
    if (_position < _totalSteps - 1) {
      _goTo(_position + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_position == 0) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/assessment/intro');
      }
      return;
    }
    _goTo(_position - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final response = await ApiService.postWithRetry(
        ApiConfig.assessmentFree,
        body: {
          'sleep': _sleep.toJson(),
          'movement': _movement.toJson(),
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
          'Free Assessment',
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
      // ── Sleep ────────────────────────────────────────────────
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

      // ── Movement ─────────────────────────────────────────────
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

      // ── Review ───────────────────────────────────────────────
      ReviewStep(
        sleep: _sleep,
        movement: _movement,
        onEdit: () => _goTo(0),
      ),
    ];
  }
}
