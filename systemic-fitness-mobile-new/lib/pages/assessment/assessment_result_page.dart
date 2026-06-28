import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/online_models/AssessmentModels.dart';
import 'package:workout/router/app_router.dart';

String _formatShortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

// ─── Label converters: numeric input → readable Indonesian copy ──
//
// These mirror the option labels in free_assessment_page.dart and
// paid_assessment_page.dart so the result page can show users what
// they actually answered without re-fetching the wizard.

String _consistencyLabel(int v) => switch (v) {
  1 => 'Sangat tidak teratur',
  3 => 'Teratur setiap hari',
  _ => 'Kadang berubah',
};
String _latencyLabel(int v) => switch (v) {
  10 => '< 15 menit',
  60 => '> 45 menit',
  _ => '15–30 menit',
};
String _morningLabel(int v) => switch (v) {
  1 => 'Lelah / pusing',
  3 => 'Segar & bertenaga',
  _ => 'Biasa saja',
};
String _wakeLabel(int v) => switch (v) {
  0 => 'Tidak pernah',
  2 => '1–2 kali',
  _ => 'Lebih dari 2x',
};
String _preSleepLabel(int v) => switch (v) {
  1 => 'Gadget / makan berat / pikiran sibuk',
  3 => 'Rutinitas relaksasi',
  _ => 'Campuran',
};
String _squatLabel(int v) => switch (v) {
  1 => 'Tidak mampu / nyeri',
  3 => 'Mampu squat penuh',
  _ => 'Bisa, tapi ada kompensasi',
};
String _hingeLabel(int v) => switch (v) {
  1 => 'Punggung melengkung',
  3 => 'Punggung netral lurus',
  _ => 'Hamstring kaku',
};
String _overheadLabel(int v) => switch (v) {
  1 => 'Bahu shrug / tertahan di depan',
  3 => 'Lurus di samping telinga',
  _ => 'Bisa lurus dengan usaha',
};

class AssessmentResultPage extends StatefulWidget {
  final String assessmentId;
  const AssessmentResultPage({super.key, required this.assessmentId});

  @override
  State<AssessmentResultPage> createState() => _AssessmentResultPageState();
}

class _AssessmentResultPageState extends State<AssessmentResultPage> {
  AssessmentResultModel? _result;
  AssessmentResultModel? _previous;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.assessmentById(widget.assessmentId),
      );
      final data = response['data'];
      if (data == null) throw Exception('Empty response');
      final current = AssessmentResultModel.fromJson(data as Map<String, dynamic>);

      // Fetch previous assessment in parallel with state update so the
      // page renders immediately; delta indicators appear as soon as the
      // second request finishes.
      setState(() {
        _result = current;
        _loading = false;
      });
      _loadPrevious();
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat hasil: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadPrevious() async {
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.assessmentPrevious(widget.assessmentId),
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) return;
      if (!mounted) return;
      setState(() {
        _previous = AssessmentResultModel.fromJson(data);
      });
    } on ApiException catch (e) {
      // 404 = first assessment ever, no comparison possible. Fine.
      if (e.statusCode != 404) {
        debugPrint('[AssessmentResult] previous fetch failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('[AssessmentResult] previous fetch error: $e');
    }
  }

  /// Days between current and previous assessment, or null if no
  /// comparison is available.
  int? get _daysSincePrevious {
    if (_previous == null || _result == null) return null;
    return _result!.createdAt.difference(_previous!.createdAt).inDays;
  }

  Color _classColor(String cls) {
    switch (cls) {
      case 'optimal':
      case 'stable':
      case 'efficient':
        return Colors.green;
      case 'compromised':
      case 'compensation':
      case 'at_risk':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _classLabel(String cls) {
    switch (cls) {
      case 'optimal':
        return 'Optimal';
      case 'compromised':
        return 'Compromised';
      case 'critical':
        return 'Critical';
      case 'stable':
        return 'Stable';
      case 'compensation':
        return 'Compensation';
      case 'dysfunction':
        return 'Dysfunction';
      case 'efficient':
        return 'Efficient';
      case 'at_risk':
        return 'At Risk';
      case 'dysregulated':
        return 'Dysregulated';
      default:
        return cls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDarkWhite,
      appBar: AppBar(
        backgroundColor: bgDarkWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: ConstantWidget.getCustomText(
          'Assessment Result',
          Colors.black,
          1,
          TextAlign.center,
          FontWeight.w600,
          18,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final r = _result!;
    final prev = _previous;
    final defMargin = ConstantWidget.getScreenPercentSize(context, 4);
    final systemDelta = prev != null ? r.scores.system - prev.scores.system : null;
    final systemScoreColor = r.scores.system >= 80
        ? Colors.green
        : r.scores.system >= 60
            ? Colors.orange
            : Colors.red;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: defMargin),
      children: [
        SizedBox(height: ConstantWidget.getScreenPercentSize(context, 2)),
        Center(
          child: CircularPercentIndicator(
            radius: 90,
            lineWidth: 14,
            percent: (r.scores.system / 100).clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${r.scores.system}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'System Score',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                if (systemDelta != null) ...[
                  const SizedBox(height: 4),
                  _DeltaChip(delta: systemDelta),
                ],
              ],
            ),
            progressColor: systemScoreColor,
            backgroundColor: subTextColor.withOpacity(0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ),
        if (prev != null) ...[
          const SizedBox(height: 16),
          _ProgressBanner(
            current: r,
            previous: prev,
            daysBetween: _daysSincePrevious ?? 0,
          ),
        ],
        const SizedBox(height: 24),
        _PillarRow(
          title: 'Sleep',
          score: r.scores.sleep,
          delta: prev != null ? r.scores.sleep - prev.scores.sleep : null,
          label: _classLabel(r.sleepClass),
          color: _classColor(r.sleepClass),
        ),
        _PillarRow(
          title: 'Movement',
          score: r.scores.movement,
          delta: prev != null ? r.scores.movement - prev.scores.movement : null,
          label: _classLabel(r.movementClass),
          color: _classColor(r.movementClass),
        ),
        if (r.scores.metabolic != null)
          _PillarRow(
            title: 'Metabolic',
            score: r.scores.metabolic!,
            delta: (prev != null && prev.scores.metabolic != null)
                ? r.scores.metabolic! - prev.scores.metabolic!
                : null,
            label: _classLabel(r.metabolicClass ?? ''),
            color: _classColor(r.metabolicClass ?? ''),
          ),
        const SizedBox(height: 24),
        if (r.flags.isNotEmpty) ...[
          const Text(
            'Risk flags',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: r.flags
                .map((f) => Chip(
                      label: Text(f, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          'Insight',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: subTextColor.withOpacity(0.2)),
          ),
          child: Text(r.insight),
        ),
        if (r.recommendations.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Recommendations',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...r.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              )),
        ],
        if (r.sleep != null || r.movement != null || r.metabolic != null) ...[
          const SizedBox(height: 24),
          _AnswersSection(
            sleep: r.sleep,
            movement: r.movement,
            metabolic: r.metabolic,
          ),
        ],
        if (r.reviewerNotes != null && r.reviewerNotes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Catatan Trainer',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Text(r.reviewerNotes!),
          ),
        ],
        const SizedBox(height: 24),
        ConstantWidget.getBorderButtonWidget(
          context,
          'Lihat Histori',
          () => context.push(AppRoutes.assessmentHistory),
        ),
        ConstantWidget.getButtonWidget(
          context,
          'Selesai',
          accentColor,
          () => context.go(AppRoutes.dashboard),
        ),
        SizedBox(height: ConstantWidget.getScreenPercentSize(context, 2)),
      ],
    );
  }
}

class _PillarRow extends StatelessWidget {
  final String title;
  final int score;
  final int? delta;
  final String label;
  final Color color;
  const _PillarRow({
    required this.title,
    required this.score,
    this.delta,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              color: color,
              backgroundColor: subTextColor.withOpacity(0.15),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (delta != null) ...[
            const SizedBox(width: 4),
            _DeltaChip(delta: delta!, compact: true),
          ],
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored pill showing a +/- delta for a score.
/// Green = improved, red = declined, grey = unchanged.
class _DeltaChip extends StatelessWidget {
  final int delta;
  final bool compact;
  const _DeltaChip({required this.delta, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (delta) {
      > 0 => (Colors.green.shade50, Colors.green.shade700, Icons.arrow_upward),
      < 0 => (Colors.red.shade50, Colors.red.shade700, Icons.arrow_downward),
      _ => (Colors.grey.shade200, Colors.grey.shade700, Icons.remove),
    };
    final sign = delta > 0 ? '+' : '';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 9 : 11, color: fg),
          const SizedBox(width: 2),
          Text(
            '$sign$delta',
            style: TextStyle(
              color: fg,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible-looking section that shows the raw inputs the user
/// answered. Helps the user remember what they actually filled in
/// when they later view their result, and supports the trainer
/// review conversation.
class _AnswersSection extends StatelessWidget {
  final SleepInputModel? sleep;
  final MovementInputModel? movement;
  final MetabolicInputModel? metabolic;
  const _AnswersSection({
    required this.sleep,
    required this.movement,
    required this.metabolic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jawaban Kamu',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Detail input yang kamu isi saat assessment ini.',
          style: TextStyle(color: subTextColor, fontSize: 12),
        ),
        const SizedBox(height: 10),
        if (sleep != null) _AnswerGroup(
          icon: Icons.bedtime_outlined,
          title: 'Sleep & Recovery',
          rows: [
            ('Durasi tidur', '${sleep!.durationHours.toStringAsFixed(1)} jam'),
            ('Konsistensi', _consistencyLabel(sleep!.consistency)),
            ('Sleep latency', _latencyLabel(sleep!.latencyMinutes)),
            ('Morning readiness', _morningLabel(sleep!.morningReadiness)),
            ('Wake frequency', _wakeLabel(sleep!.wakeFrequency)),
            ('Pre-sleep habit', _preSleepLabel(sleep!.preSleepHabit)),
          ],
        ),
        if (movement != null) _AnswerGroup(
          icon: Icons.accessibility_new,
          title: 'Movement Screening',
          rows: [
            ('Bodyweight Squat', _squatLabel(movement!.squat)),
            ('Hip Hinge', _hingeLabel(movement!.hipHinge)),
            ('Overhead Reach', _overheadLabel(movement!.overhead)),
          ],
        ),
        if (metabolic != null) _AnswerGroup(
          icon: Icons.science_outlined,
          title: 'Metabolic / Lab Values',
          rows: [
            ('HbA1c', '${metabolic!.hbA1c.toStringAsFixed(2)} %'),
            ('LDL Cholesterol', '${metabolic!.ldl.toStringAsFixed(0)} mg/dL'),
            ('Trigliserida', '${metabolic!.triglyceride.toStringAsFixed(0)} mg/dL'),
            if (metabolic!.medications.isNotEmpty)
              ('Konsumsi obat', metabolic!.medications.join(', ')),
          ],
        ),
      ],
    );
  }
}

class _AnswerGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<(String, String)> rows;
  const _AnswerGroup({
    required this.icon,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        row.$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Headline banner summarising progress vs the previous assessment.
class _ProgressBanner extends StatelessWidget {
  final AssessmentResultModel current;
  final AssessmentResultModel previous;
  final int daysBetween;
  const _ProgressBanner({
    required this.current,
    required this.previous,
    required this.daysBetween,
  });

  @override
  Widget build(BuildContext context) {
    final delta = current.scores.system - previous.scores.system;
    final (bg, border, fg, title) = switch (delta) {
      > 0 => (
          Colors.green.shade50,
          Colors.green.shade200,
          Colors.green.shade800,
          'Progress meningkat 📈',
        ),
      < 0 => (
          Colors.red.shade50,
          Colors.red.shade200,
          Colors.red.shade800,
          'System mengalami penurunan',
        ),
      _ => (
          Colors.grey.shade100,
          Colors.grey.shade300,
          Colors.grey.shade800,
          'System stabil',
        ),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            delta > 0
                ? Icons.trending_up
                : delta < 0
                    ? Icons.trending_down
                    : Icons.trending_flat,
            color: fg,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'vs assessment ${_formatShortDate(previous.createdAt)} '
                  '($daysBetween hari lalu)',
                  style: TextStyle(color: fg, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
