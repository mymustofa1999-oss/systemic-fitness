import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/online_models/AssessmentModels.dart';
import 'package:workout/router/app_router.dart';

class AssessmentHistoryPage extends StatefulWidget {
  const AssessmentHistoryPage({super.key});

  @override
  State<AssessmentHistoryPage> createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage> {
  List<AssessmentResultModel> _items = [];
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
        ApiConfig.assessmentsMine,
        queryParams: {'page': '1', 'limit': '50'},
      );
      final list = (response['data'] as List?) ?? [];
      setState(() {
        _items = list
            .map((e) => AssessmentResultModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat histori: $e';
        _loading = false;
      });
    }
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Returns the most recent assessment of the requested tier from the
  /// already-loaded list, or null if there is none.
  AssessmentResultModel? _latestOfTier(String tier) {
    for (final a in _items) {
      if (a.tier == tier) return a;
    }
    return null;
  }

  /// Soft guardrail: if the user already submitted a same-tier
  /// assessment in the last 24 hours, ask them to confirm before
  /// starting a new one. They can still proceed — this is just a
  /// reminder that assessments are typically retaken every 4–8 weeks
  /// to track progress, not multiple times per day.
  Future<bool> _confirmIfRecent(String tier) async {
    final latest = _latestOfTier(tier);
    if (latest == null) return true;
    final hours = DateTime.now().difference(latest.createdAt).inHours;
    if (hours >= 24) return true;

    final tierLabel = tier == 'paid' ? 'Paid' : 'Free';
    final hoursText = hours < 1
        ? 'beberapa menit lalu'
        : '$hours jam yang lalu';

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sudah submit baru-baru ini'),
        content: Text(
          'Kamu sudah submit $tierLabel Assessment $hoursText. '
          'Biasanya assessment di-retake setiap 4–8 minggu untuk '
          'lihat progress, bukan beberapa kali sehari.\n\n'
          'Tetap mau submit assessment baru?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: accentColor),
            child: const Text('Ya, lanjut'),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }

  Future<void> _startNew(String tier) async {
    Navigator.of(context).pop(); // close the bottom sheet first
    final ok = await _confirmIfRecent(tier);
    if (!ok || !mounted) return;
    if (tier == 'paid') {
      context.push(AppRoutes.assessmentPaid);
    } else {
      context.push(AppRoutes.assessmentFree);
    }
  }

  void _showNewAssessmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mulai Assessment Baru',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih tipe assessment yang ingin kamu isi.',
                style: TextStyle(color: subTextColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _NewAssessmentTile(
                icon: Icons.bolt_outlined,
                title: 'Free Assessment',
                subtitle: 'Sleep & Movement · 3-5 menit',
                onTap: () => _startNew('free'),
              ),
              const SizedBox(height: 8),
              _NewAssessmentTile(
                icon: Icons.workspace_premium_outlined,
                title: 'Paid Assessment',
                subtitle: 'Sleep + Movement + Lab values · butuh aktif paid plan',
                onTap: () => _startNew('paid'),
                accent: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDarkWhite,
      appBar: AppBar(
        backgroundColor: bgDarkWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: ConstantWidget.getCustomText(
          'Assessment History',
          Colors.black,
          1,
          TextAlign.center,
          FontWeight.w600,
          18,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewAssessmentSheet,
        backgroundColor: accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Assessment Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? const Center(child: Text('Belum ada assessment tersimpan'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final r = _items[i];
                          return InkWell(
                            onTap: () => context.push('/assessment/result/${r.id}'),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: subTextColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: r.scores.system >= 80
                                        ? Colors.green
                                        : r.scores.system >= 60
                                            ? Colors.orange
                                            : Colors.red,
                                    radius: 26,
                                    child: Text(
                                      '${r.scores.system}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.tier == 'paid'
                                              ? 'Paid Assessment'
                                              : 'Free Assessment',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_fmtDate(r.createdAt)} • ${r.status}',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _NewAssessmentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;
  const _NewAssessmentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent ? accentColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent
                ? accentColor.withOpacity(0.3)
                : subTextColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent
                    ? accentColor.withOpacity(0.12)
                    : subTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent ? accentColor : Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
