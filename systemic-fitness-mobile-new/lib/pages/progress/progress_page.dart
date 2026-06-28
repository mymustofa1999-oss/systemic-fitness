import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/progress_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/empty_state_widget.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/pages/progress/workout_sessions_tab.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isChartLoading = true;
  String? _error;
  String? _chartError;
  List<ProgressLog> _progressLogs = [];
  List<ChartDataPoint> _weightChart = [];
  List<ChartDataPoint> _volumeChart = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await PrefData.getUser();
    _userId = user?.id;
    if (_userId == null) return;
    await Future.wait([_fetchHistory(), _fetchCharts()]);
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.progressHistory(_userId!),
      );
      final data = response['data'];
      final List<ProgressLog> logs = [];
      if (data is List) {
        for (final item in data) {
          logs.add(ProgressLog.fromJson(item));
        }
      }
      if (mounted) {
        setState(() {
          _progressLogs = logs;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load progress history.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCharts() async {
    setState(() {
      _isChartLoading = true;
      _chartError = null;
    });
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.progressCharts(_userId!),
      );
      final data = response['data'];
      final List<ChartDataPoint> weight = [];
      final List<ChartDataPoint> volume = [];
      if (data is Map<String, dynamic>) {
        if (data['weight'] is List) {
          for (final item in data['weight']) {
            weight.add(ChartDataPoint.fromJson(item));
          }
        }
        if (data['volume'] is List) {
          for (final item in data['volume']) {
            volume.add(ChartDataPoint.fromJson(item));
          }
        }
      }
      if (mounted) {
        setState(() {
          _weightChart = weight;
          _volumeChart = volume;
          _isChartLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _chartError = e.message;
          _isChartLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chartError = 'Failed to load chart data.';
          _isChartLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _moodIcon(String? mood) {
    switch (mood) {
      case 'great':
        return '😁';
      case 'good':
        return '😊';
      case 'okay':
        return '😐';
      case 'tired':
        return '😴';
      case 'bad':
        return '😞';
      default:
        return '';
    }
  }

  String _setsSummary(List<SetData>? sets) {
    if (sets == null || sets.isEmpty) return 'No sets';
    final count = sets.length;
    final totalReps = sets.fold<int>(0, (sum, s) => sum + (s.reps ?? 0));
    return '$count sets, $totalReps reps';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Progress',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: accentColor),
            onPressed: () => context.push(AppRoutes.bodyMetrics),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: subTextColor,
          indicatorColor: accentColor,
          labelStyle: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Sesi'),
            Tab(text: 'History'),
            Tab(text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const WorkoutSessionsTab(),
          _buildHistoryTab(),
          _buildChartsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.logProgress),
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchHistory,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_progressLogs.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.fitness_center,
        title: 'No Progress Logged',
        subtitle: 'Mulai log sesi anda untuk pantau progres.',
        buttonText: 'Log Progress',
        onButtonPressed: () => context.push(AppRoutes.logProgress),
      );
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _progressLogs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = _progressLogs[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: blueButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.fitness_center, color: blueButton, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseName ?? 'Exercise',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _setsSummary(log.sets),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(log.loggedAt),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (log.mood != null)
                  Text(
                    _moodIcon(log.mood),
                    style: const TextStyle(fontSize: 24),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartsTab() {
    if (_isChartLoading) {
      return const Center(child: LoadingWidget());
    }
    if (_chartError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _chartError!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchCharts,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_weightChart.isEmpty && _volumeChart.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'No Chart Data',
        subtitle: 'Log lebih banyak sesi untuk lihat grafik progres.',
      );
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_weightChart.isNotEmpty) ...[
            Text(
              'Weight Progression',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSimpleChart(_weightChart, blueButton),
            const SizedBox(height: 24),
          ],
          if (_volumeChart.isNotEmpty) ...[
            Text(
              'Volume Progression',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSimpleChart(_volumeChart, greenButton),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<ChartDataPoint> points, Color color) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxVal = points.fold<double>(0, (max, p) => (p.value ?? 0) > max ? (p.value ?? 0) : max);
    final minVal = points.fold<double>(double.infinity, (min, p) => (p.value ?? 0) < min ? (p.value ?? 0) : min);
    final range = maxVal - minVal;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        size: Size(double.infinity, 168),
        painter: _ChartPainter(
          points: points,
          color: color,
          maxVal: maxVal,
          minVal: minVal,
          range: range,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;
  final Color color;
  final double maxVal;
  final double minVal;
  final double range;

  _ChartPainter({
    required this.points,
    required this.color,
    required this.maxVal,
    required this.minVal,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final safeRange = range == 0 ? 1.0 : range;

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1 ? size.width / 2 : (i / (points.length - 1)) * size.width;
      final normalized = ((points[i].value ?? 0) - minVal) / safeRange;
      final y = size.height - (normalized * size.height * 0.85) - (size.height * 0.05);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    fillPath.lineTo(
      points.length == 1 ? size.width / 2 : size.width,
      size.height,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
