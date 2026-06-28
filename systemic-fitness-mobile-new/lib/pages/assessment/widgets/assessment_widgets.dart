import 'package:flutter/material.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/online_models/AssessmentModels.dart';

// ════════════════════════════════════════════════════════════════════
//  Shared assessment wizard widgets — used by both Free and Paid pages.
// ════════════════════════════════════════════════════════════════════

/// One choice in a single-select option step.
class AssessmentOption {
  final String label;
  final int value;
  const AssessmentOption(this.label, this.value);
}

/// Step progress bar (horizontal segments).
class StepProgressBar extends StatelessWidget {
  final int total;
  final int current;
  const StepProgressBar({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
        vertical: ConstantWidget.getScreenPercentSize(context, 2),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(total, (i) {
              final completed = i <= current;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: completed
                        ? accentColor
                        : subTextColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${current + 1} / $total',
              style: TextStyle(color: subTextColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-select option step (used for sleep + movement questions).
class OptionsStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AssessmentOption> options;
  final int value;
  final ValueChanged<int> onChanged;

  const OptionsStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstantWidget.getCustomText(
            title,
            Colors.black,
            1,
            TextAlign.left,
            FontWeight.w700,
            ConstantWidget.getScreenPercentSize(context, 3.2),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 3)),
          ...options.map((opt) => _OptionTile(
                label: opt.label,
                selected: opt.value == value,
                onTap: () => onChanged(opt.value),
              )),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : subTextColor.withOpacity(0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accentColor : subTextColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slider step for sleep duration (visual large value).
class DurationStep extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const DurationStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstantWidget.getCustomText(
            'Durasi tidur',
            Colors.black,
            1,
            TextAlign.left,
            FontWeight.w700,
            ConstantWidget.getScreenPercentSize(context, 3.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Rata-rata berapa jam kamu tidur per malam?',
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 6)),
          Center(
            child: Column(
              children: [
                Text(
                  '${value.toStringAsFixed(1)} jam',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                Slider(
                  value: value,
                  min: 3,
                  max: 12,
                  divisions: 18,
                  activeColor: accentColor,
                  onChanged: onChanged,
                ),
                Text(
                  'Geser untuk menyesuaikan',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decimal lab value step with helper info dialog.
class LabValueStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final String unit;
  final String helperTitle;
  final String helperBody;
  final TextEditingController controller;
  const LabValueStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.helperTitle,
    required this.helperBody,
    required this.controller,
  });

  void _showHelper(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(helperTitle),
        content: Text(helperBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ConstantWidget.getCustomText(
                  title,
                  Colors.black,
                  1,
                  TextAlign.left,
                  FontWeight.w700,
                  ConstantWidget.getScreenPercentSize(context, 3.2),
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: accentColor),
                tooltip: 'Apa ini?',
                onPressed: () => _showHelper(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 4)),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: TextStyle(color: subTextColor, fontSize: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Free-text medications step (paid only, optional).
class MedicationsStep extends StatelessWidget {
  final TextEditingController controller;
  const MedicationsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstantWidget.getCustomText(
            'Medikasi (opsional)',
            Colors.black,
            1,
            TextAlign.left,
            FontWeight.w700,
            ConstantWidget.getScreenPercentSize(context, 3.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Sebutkan obat yang sedang kamu konsumsi rutin. Pisahkan dengan koma jika lebih dari satu. Boleh dikosongkan.',
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 4)),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'mis. Metformin, Lisinopril',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Final review step showing all answers before submit.
class ReviewStep extends StatelessWidget {
  final SleepInputModel sleep;
  final MovementInputModel movement;
  final MetabolicInputModel? metabolic;
  final VoidCallback onEdit;

  const ReviewStep({
    super.key,
    required this.sleep,
    required this.movement,
    this.metabolic,
    required this.onEdit,
  });

  String _consistencyLabel(int v) => switch (v) {
        1 => 'Sangat tidak teratur',
        2 => 'Kadang berubah',
        _ => 'Teratur',
      };

  String _latencyLabel(int v) {
    if (v <= 15) return '< 15 menit (cepat)';
    if (v <= 30) return '15-30 menit (normal)';
    return '> 45 menit (lama)';
  }

  String _scaleLabel(int v) => switch (v) {
        1 => 'Rendah',
        2 => 'Sedang',
        _ => 'Tinggi',
      };

  String _wakeLabel(int v) {
    if (v == 0) return 'Tidak pernah';
    if (v <= 2) return '1-2 kali';
    return 'Lebih dari 2 kali';
  }

  String _movementLabel(int v) => switch (v) {
        1 => 'Tidak mampu / nyeri',
        2 => 'Bisa dengan kompensasi',
        _ => 'Optimal',
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ConstantWidget.getScreenPercentSize(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstantWidget.getCustomText(
            'Review jawabanmu',
            Colors.black,
            1,
            TextAlign.left,
            FontWeight.w700,
            ConstantWidget.getScreenPercentSize(context, 3.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan semua sudah benar sebelum submit. Tap "Edit" untuk kembali ke step sebelumnya.',
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 3)),
          _ReviewSection(
            title: 'Sleep',
            items: [
              _ReviewItem('Durasi tidur', '${sleep.durationHours.toStringAsFixed(1)} jam'),
              _ReviewItem('Konsistensi', _consistencyLabel(sleep.consistency)),
              _ReviewItem('Sleep latency', _latencyLabel(sleep.latencyMinutes)),
              _ReviewItem('Morning readiness', _scaleLabel(sleep.morningReadiness)),
              _ReviewItem('Wake frequency', _wakeLabel(sleep.wakeFrequency)),
              _ReviewItem('Pre-sleep habit', _scaleLabel(sleep.preSleepHabit)),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewSection(
            title: 'Movement',
            items: [
              _ReviewItem('Squat', _movementLabel(movement.squat)),
              _ReviewItem('Hip hinge', _movementLabel(movement.hipHinge)),
              _ReviewItem('Overhead reach', _movementLabel(movement.overhead)),
            ],
          ),
          if (metabolic != null) ...[
            const SizedBox(height: 12),
            _ReviewSection(
              title: 'Metabolic (Lab)',
              items: [
                _ReviewItem('HbA1c', '${metabolic!.hbA1c.toStringAsFixed(2)} %'),
                _ReviewItem('LDL', '${metabolic!.ldl.toStringAsFixed(0)} mg/dL'),
                _ReviewItem('Trigliserida', '${metabolic!.triglyceride.toStringAsFixed(0)} mg/dL'),
                _ReviewItem(
                  'Medikasi',
                  metabolic!.medications.isEmpty
                      ? '—'
                      : metabolic!.medications.join(', '),
                ),
              ],
            ),
          ],
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 2)),
          Center(
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit jawaban'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  const _ReviewItem(this.label, this.value);
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewItem> items;
  const _ReviewSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Divider(),
          ...items.map((it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        it.label,
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        it.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
