import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/notification_model.dart';
import 'package:workout/models/pagination_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _page < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.notifications,
        queryParams: {'page': '1', 'limit': '20'},
      );

      final List<dynamic> data = response['data'] ?? [];
      final meta = response['meta'];

      setState(() {
        _notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
        _page = 1;
        if (meta != null) {
          final pagination = PaginationMeta.fromJson(meta);
          _totalPages = pagination.totalPages;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _page + 1;
      final response = await ApiService.getWithRetry(
        ApiConfig.notifications,
        queryParams: {'page': '$nextPage', 'limit': '20'},
      );

      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _notifications.addAll(data.map((e) => NotificationModel.fromJson(e)));
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _markAsRead(String notifId) async {
    try {
      await ApiService.postWithRetry(ApiConfig.notificationRead(notifId));
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notifId);
        if (index != -1) {
          _notifications[index].status = 'read';
          _notifications[index].readAt = DateTime.now().toIso8601String();
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.postWithRetry(ApiConfig.notificationReadAll);
      setState(() {
        for (var n in _notifications) {
          n.status = 'read';
          n.readAt = DateTime.now().toIso8601String();
        }
      });
      Fluttertoast.showToast(msg: 'All notifications marked as read');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to mark all as read');
    }
  }

  void _onNotificationTap(NotificationModel notif) {
    // Mark as read
    if (notif.isUnread && notif.id != null) {
      _markAsRead(notif.id!);
    }

    // Navigate based on notification data
    final data = notif.data;
    if (data != null) {
      final type = data['type'] as String?;
      final targetId = data['target_id'] as String?;

      switch (type) {
        case 'workout_reminder':
          if (targetId != null) {
            context.push('/workouts/$targetId/session');
          }
          break;
        case 'program_reminder':
          context.push(AppRoutes.activeProgram);
          break;
        case 'subscription_expiring':
        case 'payment_due':
        case 'promo':
          context.push(AppRoutes.subscription);
          break;
        case 'new_message':
          if (targetId != null) {
            context.push('/messages/$targetId');
          }
          break;
        case 'milestone':
        case 'on_program_complete':
          context.push(AppRoutes.progress);
          break;
        case 'body_metric_reminder':
          context.push(AppRoutes.logBodyMetric);
          break;
        case 'nutrition_reminder':
          context.push(AppRoutes.logNutrition);
          break;
      }
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'workout_reminder':
      case 'program_reminder':
        return Icons.fitness_center;
      case 'subscription_expiring':
      case 'payment_due':
        return Icons.payment;
      case 'new_message':
        return Icons.chat_bubble;
      case 'milestone':
        return Icons.emoji_events;
      case 'promo':
        return Icons.local_offer;
      case 'announcement':
        return Icons.campaign;
      case 'maintenance':
        return Icons.build;
      case 'body_metric_reminder':
        return Icons.monitor_weight;
      case 'nutrition_reminder':
        return Icons.restaurant;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'workout_reminder':
      case 'program_reminder':
        return blueButton;
      case 'subscription_expiring':
      case 'payment_due':
        return Colors.orange;
      case 'new_message':
        return greenButton;
      case 'milestone':
        return Colors.amber;
      case 'promo':
        return Colors.purple;
      case 'announcement':
        return Colors.teal;
      case 'maintenance':
        return Colors.grey;
      default:
        return accentColor;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_notifications.any((n) => n.isUnread))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Read All',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: subTextColor)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.notifications_none,
                      title: 'No Notifications',
                      subtitle: 'You\'re all caught up!',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _notifications.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildNotificationTile(_notifications[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    final iconColor = _getNotificationColor(notif.type);

    return InkWell(
      onTap: () => _onNotificationTap(notif),
      child: Container(
        color: notif.isUnread ? blueButton.withValues(alpha: 0.05) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notif.type),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title ?? '',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontWeight: notif.isUnread ? FontWeight.bold : FontWeight.w500,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notif.createdAt),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body ?? '',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: subTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread dot
            if (notif.isUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: blueButton,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
