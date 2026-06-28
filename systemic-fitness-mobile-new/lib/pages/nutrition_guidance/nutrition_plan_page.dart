import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/data/api_service.dart';
import 'package:workout/data/nutrition_guidance_repository.dart';
import 'package:workout/models/nutrition_guidance_model.dart';
import 'package:workout/router/app_router.dart';

class NutritionPlanPage extends StatefulWidget {
  const NutritionPlanPage({super.key});

  @override
  State<NutritionPlanPage> createState() => _NutritionPlanPageState();
}

class _NutritionPlanPageState extends State<NutritionPlanPage> {
  NutritionPlanResult? _plan;
  NutritionDailyLogResult? _todayLog; // non-null only if user logged today
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static String _todayString() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch plan and most-recent log in parallel. The recent-logs call is
      // only used to detect whether the user has already logged today, so
      // failures there should NOT block rendering the plan.
      final planFuture = NutritionGuidanceRepository.getPlan();
      final recentFuture = NutritionGuidanceRepository.listRecentLogs(limit: 1)
          .catchError((_) => <NutritionDailyLogResult>[]);

      final plan = await planFuture;
      final recent = await recentFuture;
      if (!mounted) return;

      final today = _todayString();
      NutritionDailyLogResult? todayLog;
      if (recent.isNotEmpty && recent.first.logDate == today) {
        todayLog = recent.first;
      }

      setState(() {
        _plan = plan;
        _todayLog = todayLog;
        _loading = false;
      });
    } on PaidSubscriptionRequiredException {
      if (!mounted) return;
      context.pushReplacement(AppRoutes.nutritionGuidanceUpgrade);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 404) {
        context.pushReplacement(AppRoutes.nutritionGuidanceProfile);
        return;
      }
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'stable':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _foodList(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items
                  .map((f) => Chip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        backgroundColor: color.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedToday = _todayLog != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Nutrisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Log',
            onPressed: () async {
              await context.push(AppRoutes.nutritionGuidanceHistory);
              _load();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: loggedToday ? Colors.orange : null,
        onPressed: () async {
          await context.push(AppRoutes.nutritionGuidanceDailyLog);
          _load();
        },
        icon: Icon(loggedToday ? Icons.edit : Icons.edit_note),
        label: Text(loggedToday ? 'Ubah Log Hari Ini' : 'Log Hari Ini'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _todayLogStatusCard(),
                      const SizedBox(height: 12),
                      _scoreCard(),
                      const SizedBox(height: 12),
                      _foodList('Boleh Dikonsumsi',
                          _plan!.dietPlan.allowedFoods, Colors.green),
                      _foodList('Batasi', _plan!.dietPlan.limitedFoods,
                          Colors.orange),
                      _foodList(
                          'Hindari', _plan!.dietPlan.avoidFoods, Colors.red),
                      const SizedBox(height: 12),
                      _rulesCard(),
                      const SizedBox(height: 12),
                      _insightCard(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  /// Compact banner at the top of the plan page telling the user whether
  /// they've already submitted today's log.
  Widget _todayLogStatusCard() {
    final logged = _todayLog != null;
    final bgColor = logged ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = logged ? Colors.green : Colors.orange;
    final icon = logged ? Icons.check_circle : Icons.pending_actions;
    final title =
        logged ? 'Log hari ini sudah tersimpan' : 'Belum log hari ini';
    final subtitle = logged
        ? 'Skor: ${_todayLog!.dailyScore} • ${_todayLog!.status.toUpperCase()}'
        : 'Tandai kepatuhan nutrisimu agar skor harianmu tercatat.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.push(AppRoutes.nutritionGuidanceHistory);
              _load();
            },
            child: const Text('Riwayat'),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard() {
    final color = _statusColor(_plan!.status);
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color,
              child: Text('${_plan!.dailyScore}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skor Hari Ini',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(_plan!.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rulesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aturan Nutrisi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._plan!.nutritionRules.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• ${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard() {
    if (_plan!.insight.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Insight',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._plan!.insight.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $i', style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
