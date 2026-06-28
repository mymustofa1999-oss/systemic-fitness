import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _loggingIds = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(ApiConfig.habits);
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _habits = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data habits';
        _isLoading = false;
      });
    }
  }

  Future<void> _logHabit(String habitId) async {
    if (_loggingIds.contains(habitId)) return;
    setState(() => _loggingIds.add(habitId));

    try {
      await ApiService.postWithRetry(
        ApiConfig.habitLog,
        body: {
          'habit_id': habitId,
          'logged_at': DateTime.now().toIso8601String().split('T')[0],
          'completed': true,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit berhasil dicatat!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh list untuk update status
      _loadHabits();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencatat habit'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loggingIds.remove(habitId));
    }
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
          'Habits',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 56, color: subTextColor),
                      const SizedBox(height: 16),
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
                        onPressed: _loadHabits,
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            color: blueButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _habits.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.checklist_rounded,
                      title: 'Belum Ada Habit',
                      subtitle: 'Belum ada habit yang tersedia.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHabits,
                      color: accentColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _habits.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final habit = _habits[index];
                          final habitId =
                              (habit['id'] ?? '').toString();
                          final name =
                              (habit['name'] ?? '-').toString();
                          final description =
                              (habit['description'] ?? '').toString();
                          final loggedToday =
                              habit['logged_today'] == true;
                          final isLogging =
                              _loggingIds.contains(habitId);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getCellColor(index),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily:
                                              Constants.fontsFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily:
                                                Constants.fontsFamily,
                                            fontSize: 12,
                                            color: subTextColor,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            loggedToday
                                                ? Icons.check_circle
                                                : Icons
                                                    .radio_button_unchecked,
                                            size: 16,
                                            color: loggedToday
                                                ? greenButton
                                                : subTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            loggedToday
                                                ? 'Sudah dicatat hari ini'
                                                : 'Belum dicatat hari ini',
                                            style: TextStyle(
                                              fontFamily:
                                                  Constants.fontsFamily,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w500,
                                              color: loggedToday
                                                  ? greenButton
                                                  : subTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: loggedToday || isLogging
                                        ? null
                                        : () => _logHabit(habitId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: loggedToday
                                          ? subTextColor
                                              .withOpacity(0.3)
                                          : accentColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14),
                                    ),
                                    child: isLogging
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            loggedToday
                                                ? 'Selesai'
                                                : 'Catat',
                                            style: TextStyle(
                                              fontFamily:
                                                  Constants.fontsFamily,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
