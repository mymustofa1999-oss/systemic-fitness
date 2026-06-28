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

class BodyMetricsPage extends StatefulWidget {
  const BodyMetricsPage({super.key});

  @override
  State<BodyMetricsPage> createState() => _BodyMetricsPageState();
}

class _BodyMetricsPageState extends State<BodyMetricsPage> {
  bool _isLoading = true;
  String? _error;
  List<BodyMetric> _metrics = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await PrefData.getUser();
    _userId = user?.id;
    if (_userId == null) return;
    await _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.bodyMetrics(_userId!),
      );
      final data = response['data'];
      final List<BodyMetric> metrics = [];
      if (data is List) {
        for (final item in data) {
          metrics.add(BodyMetric.fromJson(item));
        }
      }
      if (mounted) {
        setState(() {
          _metrics = metrics;
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
          _error = 'Failed to load body metrics.';
          _isLoading = false;
        });
      }
    }
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

  List<ChartDataPoint> _buildWeightChartData() {
    return _metrics
        .where((m) => m.weightKg != null && m.loggedAt != null)
        .map((m) => ChartDataPoint(date: m.loggedAt, value: m.weightKg))
        .toList()
        .reversed
        .toList();
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
          'Body Metrics',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.logBodyMetric);
          _fetchMetrics();
        },
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
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
              onPressed: _fetchMetrics,
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
    if (_metrics.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.monitor_weight_outlined,
        title: 'No Body Metrics',
        subtitle: 'Start tracking your body measurements.',
        buttonText: 'Log Metric',
        onButtonPressed: () => context.push(AppRoutes.logBodyMetric),
      );
    }

    final chartData = _buildWeightChartData();

    return RefreshIndicator(
      onRefresh: _fetchMetrics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weight chart
          if (chartData.length >= 2) ...[
            Text(
              'Weight Over Time',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSimpleChart(chartData),
            const SizedBox(height: 24),
          ],

          // Metrics list
          Text(
            'History',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._metrics.map((metric) => _buildMetricCard(metric)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BodyMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(metric.loggedAt),
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              if (metric.notes != null && metric.notes!.isNotEmpty)
                Icon(Icons.notes, size: 18, color: subTextColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (metric.weightKg != null)
                _buildMetricChip('Weight', '${metric.weightKg!.toStringAsFixed(1)} kg'),
              if (metric.bodyFatPct != null)
                _buildMetricChip('Body Fat', '${metric.bodyFatPct!.toStringAsFixed(1)}%'),
              if (metric.muscleMassKg != null)
                _buildMetricChip('Muscle', '${metric.muscleMassKg!.toStringAsFixed(1)} kg'),
            ],
          ),
          if (metric.notes != null && metric.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              metric.notes!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 13,
                color: subTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 11,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<ChartDataPoint> points) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxVal = points.fold<double>(0, (max, p) => (p.value ?? 0) > max ? (p.value ?? 0) : max);
    final minVal = points.fold<double>(double.infinity, (min, p) => (p.value ?? 0) < min ? (p.value ?? 0) : min);
    final range = maxVal - minVal;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 148),
        painter: _WeightChartPainter(
          points: points,
          color: blueButton,
          maxVal: maxVal,
          minVal: minVal,
          range: range,
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;
  final Color color;
  final double maxVal;
  final double minVal;
  final double range;

  _WeightChartPainter({
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
