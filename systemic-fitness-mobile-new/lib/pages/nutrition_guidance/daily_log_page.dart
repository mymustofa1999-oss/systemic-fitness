import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/data/api_service.dart';
import 'package:workout/data/nutrition_guidance_repository.dart';
import 'package:workout/models/nutrition_guidance_model.dart';
import 'package:workout/router/app_router.dart';

class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  bool _vegetable = false;
  bool _protein = false;
  bool _hydration = false;
  bool _sugarExcess = false;
  bool _dietViolation = false;
  bool _saving = false;

  String _today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<bool> _confirmBeforeSubmit() async {
    final positives = <String>[
      if (_vegetable) 'Konsumsi sayur cukup (+20)',
      if (_protein) 'Konsumsi protein cukup (+20)',
      if (_hydration) 'Hidrasi cukup (+20)',
    ];
    final negatives = <String>[
      if (_sugarExcess) 'Konsumsi gula berlebih (-20)',
      if (_dietViolation) 'Melanggar pantangan diet (-20)',
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Konfirmasi Submit')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan pilihanmu sudah benar. Setelah disubmit, log hari ini tidak bisa diubah lagi.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (positives.isNotEmpty) ...[
              const Text('Poin positif:',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...positives.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (negatives.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'PERINGATAN: Kamu akan mencatat pelanggaran berikut',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...negatives.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text('• $e',
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Poin akan dikurangi. Pastikan ini benar.',
                      style: TextStyle(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (positives.isEmpty && negatives.isEmpty)
              const Text(
                'Belum ada item yang dicentang. Yakin ingin submit log kosong?',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  negatives.isNotEmpty ? Colors.red : null,
              foregroundColor:
                  negatives.isNotEmpty ? Colors.white : null,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Submit'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _submit() async {
    final ok = await _confirmBeforeSubmit();
    if (!mounted || !ok) return;

    setState(() => _saving = true);
    try {
      final res = await NutritionGuidanceRepository.submitDailyLog(
        NutritionDailyLogInput(
          logDate: _today(),
          vegetableIntake: _vegetable,
          proteinIntake: _protein,
          hydrationOk: _hydration,
          sugarExcess: _sugarExcess,
          dietViolation: _dietViolation,
        ),
      );
      if (!mounted) return;
      await _showResult(res);
      if (!mounted) return;
      context.pop();
    } on PaidSubscriptionRequiredException {
      if (!mounted) return;
      context.go(AppRoutes.nutritionGuidanceUpgrade);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showResult(NutritionDailyLogResult res) async {
    final color = res.status == 'stable'
        ? Colors.green
        : res.status == 'warning'
            ? Colors.orange
            : Colors.red;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Skor: ${res.dailyScore}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${res.status.toUpperCase()}',
                style: TextStyle(color: color)),
            if (res.alert != null && res.alert!.triggered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peringatan: ${res.alert!.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Nutrisi Hari Ini')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tandai yang sudah kamu lakukan hari ini:',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketuk kartu di bawah untuk memilih. Belum dipilih berarti tidak dihitung.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleCard(
            title: 'Konsumsi sayur cukup',
            subtitle: '+20 poin',
            value: _vegetable,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _vegetable = v),
          ),
          _buildToggleCard(
            title: 'Konsumsi protein cukup',
            subtitle: '+20 poin',
            value: _protein,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _protein = v),
          ),
          _buildToggleCard(
            title: 'Hidrasi cukup',
            subtitle: '+20 poin',
            value: _hydration,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _hydration = v),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildToggleCard(
            title: 'Konsumsi gula berlebih',
            subtitle: '-20 poin',
            value: _sugarExcess,
            activeColor: Colors.red,
            onChanged: (v) => setState(() => _sugarExcess = v),
          ),
          _buildToggleCard(
            title: 'Melanggar pantangan diet',
            subtitle: '-20 poin',
            value: _dietViolation,
            activeColor: Colors.red,
            onChanged: (v) => setState(() => _dietViolation = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Log Hari Ini'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    final borderColor = value ? activeColor : Colors.grey.shade400;
    final bgColor = value ? activeColor.withOpacity(0.08) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: value ? 2 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  value
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: value ? activeColor : Colors.grey.shade500,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: value ? activeColor : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: value
                              ? activeColor.withOpacity(0.8)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: value,
                  activeColor: activeColor,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
