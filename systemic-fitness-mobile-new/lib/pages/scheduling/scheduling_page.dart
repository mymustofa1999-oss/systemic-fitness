import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.schedulingEvents,
      );
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _events = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
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
          'Jadwal',
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
                        onPressed: _loadEvents,
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
              : _events.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.calendar_today_outlined,
                      title: 'Belum Ada Jadwal',
                      subtitle: 'Belum ada event yang dijadwalkan.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      color: accentColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final name =
                              (event['name'] ?? event['title'] ?? '-')
                                  .toString();
                          final eventType =
                              (event['event_type'] ?? event['type'] ?? '')
                                  .toString();
                          final startTime =
                              (event['start_time'] ??
                                      event['start_date'] ??
                                      '')
                                  .toString();
                          final participantsCount =
                              event['participants_count'] ??
                                  event['participant_count'] ??
                                  0;

                          final dateStr = _formatDate(startTime);
                          final timeStr = _formatTime(startTime);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getCellColor(index),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Date badge
                                Container(
                                  width: 52,
                                  padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.7),
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: accentColor,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr,
                                        textAlign:
                                            TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: Constants
                                              .fontsFamily,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: Constants
                                              .fontsFamily,
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (timeStr
                                              .isNotEmpty) ...[
                                            Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color:
                                                  subTextColor,
                                            ),
                                            const SizedBox(
                                                width: 4),
                                            Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontFamily:
                                                    Constants
                                                        .fontsFamily,
                                                fontSize: 12,
                                                color:
                                                    subTextColor,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 12),
                                          ],
                                          if (eventType
                                              .isNotEmpty) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color: accentColor
                                                    .withOpacity(
                                                        0.1),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            8),
                                              ),
                                              child: Text(
                                                eventType
                                                    .toUpperCase(),
                                                style:
                                                    TextStyle(
                                                  fontFamily:
                                                      Constants
                                                          .fontsFamily,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                  color:
                                                      accentColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 14,
                                            color: subTextColor,
                                          ),
                                          const SizedBox(
                                              width: 4),
                                          Text(
                                            '$participantsCount peserta',
                                            style: TextStyle(
                                              fontFamily:
                                                  Constants
                                                      .fontsFamily,
                                              fontSize: 11,
                                              color:
                                                  subTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
