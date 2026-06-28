import 'package:flutter/material.dart';

import '../../../ColorCategory.dart';
import '../../../data/api_config.dart';
import '../../../data/api_service.dart';
import '../../../online_models/AssessmentV2Models.dart';
import '../../../util/sf_typography.dart';

/// Show modal bottom sheet untuk pilih klasifikasi kondisi (5 kategori).
/// Returns slug dari klasifikasi terpilih (atau null kalau di-dismiss).
Future<String?> showClassificationPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ClassificationPicker(),
  );
}

/// Show modal bottom sheet untuk pilih kondisi spesifik dari klasifikasi.
/// Returns slug dari kondisi terpilih (atau null kalau di-dismiss).
Future<String?> showSpecificConditionPicker(
  BuildContext context, {
  required String classificationSlug,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SpecificConditionPicker(
      classificationSlug: classificationSlug,
    ),
  );
}

class _ClassificationPicker extends StatefulWidget {
  @override
  State<_ClassificationPicker> createState() => _ClassificationPickerState();
}

class _ClassificationPickerState extends State<_ClassificationPicker> {
  bool _loading = true;
  String? _error;
  List<ConditionClassificationModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.masterConditionClassifications,
      );
      final List<dynamic> data = res['data'] ?? const [];
      if (mounted) {
        setState(() {
          _items = data
              .map((e) => ConditionClassificationModel.fromJson(
                  e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Gagal memuat klasifikasi.\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerShell(
      title: 'Klasifikasi Kondisi',
      subtitle: 'Pilih kategori yang paling mendekati.',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: kSfWarmGold),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: SfTypography.body(fontSize: 13, color: Colors.red.shade700),
        ),
      );
    }
    return Column(
      children: _items.map((c) {
        return InkWell(
          onTap: () => Navigator.pop(context, c.slug),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kSfCharcoal.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _pillarColor(c.focusPillar).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      c.focusPillar,
                      style: SfTypography.label(
                        fontSize: 11,
                        color: _pillarColor(c.focusPillar),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.label,
                        style: SfTypography.subheadline(
                          fontSize: 15, color: kSfCharcoal,
                        ),
                      ),
                      if (c.description != null && c.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            c.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SfTypography.body(
                              fontSize: 12,
                              color: kSfCharcoal.withOpacity(0.6),
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: kSfCharcoal.withOpacity(0.4)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _pillarColor(String p) {
    switch (p) {
      case 'FC': return kSfDeepTeal;
      case 'CC': return kSfSystemBlue;
      case 'MC': return kSfWarmGold;
    }
    return kSfCharcoal;
  }
}

class _SpecificConditionPicker extends StatefulWidget {
  final String classificationSlug;

  const _SpecificConditionPicker({required this.classificationSlug});

  @override
  State<_SpecificConditionPicker> createState() =>
      _SpecificConditionPickerState();
}

class _SpecificConditionPickerState extends State<_SpecificConditionPicker> {
  bool _loading = true;
  String? _error;
  List<SpecificConditionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.masterSpecificConditions,
        queryParams: {'classification': widget.classificationSlug},
      );
      final List<dynamic> data = res['data'] ?? const [];
      if (mounted) {
        setState(() {
          _items = data
              .map((e) => SpecificConditionModel.fromJson(
                  e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Gagal memuat kondisi.\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerShell(
      title: 'Kondisi Spesifik',
      subtitle: 'Pilih yang paling mendekati diagnosa anda.',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: kSfWarmGold),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: SfTypography.body(fontSize: 13, color: Colors.red.shade700),
        ),
      );
    }
    return Column(
      children: _items.map((c) {
        return InkWell(
          onTap: () => Navigator.pop(context, c.slug),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kSfCharcoal.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.label,
                        style: SfTypography.body(
                          fontSize: 14, color: kSfCharcoal,
                          weight: FontWeight.w500,
                        ),
                      ),
                      if (c.severityDefault != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _severityColor(c.severityDefault!)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              c.severityDefault!.toUpperCase(),
                              style: SfTypography.label(
                                fontSize: 9,
                                color: _severityColor(c.severityDefault!),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: kSfCharcoal.withOpacity(0.4)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _severityColor(String s) {
    switch (s) {
      case 'severe': return Colors.red.shade700;
      case 'moderate': return Colors.amber.shade700;
      case 'mild': return Colors.green.shade700;
      case 'monitor': return kSfSystemBlue;
    }
    return kSfCharcoal;
  }
}

/// Bottom sheet shell — header sticky + scrollable content.
class _PickerShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PickerShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: kSfWarmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: kSfCharcoal.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SfTypography.headline(
                        fontSize: 22, color: kSfCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: SfTypography.body(
                        fontSize: 13,
                        color: kSfCharcoal.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
