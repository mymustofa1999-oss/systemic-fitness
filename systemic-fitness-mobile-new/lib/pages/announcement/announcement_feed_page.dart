import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/announcement_model.dart';
import 'package:workout/models/pagination_model.dart';
import 'package:workout/widgets/announcement_card.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class AnnouncementFeedPage extends StatefulWidget {
  const AnnouncementFeedPage({super.key});

  @override
  State<AnnouncementFeedPage> createState() => _AnnouncementFeedPageState();
}

class _AnnouncementFeedPageState extends State<AnnouncementFeedPage> {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
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

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.announcementsFeed,
        queryParams: {'page': '1', 'limit': '20'},
      );

      final List<dynamic> data = response['data'] ?? [];
      final meta = response['meta'];

      setState(() {
        _announcements =
            data.map((e) => AnnouncementModel.fromJson(e)).toList();
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
        ApiConfig.announcementsFeed,
        queryParams: {'page': '$nextPage', 'limit': '20'},
      );

      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _announcements
            .addAll(data.map((e) => AnnouncementModel.fromJson(e)));
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onAnnouncementTap(int index) async {
    final announcement = _announcements[index];

    // Mark as read
    if (announcement.isUnread && announcement.id != null) {
      try {
        await ApiService.postWithRetry(
            ApiConfig.announcementRead(announcement.id!));
        setState(() {
          _announcements[index].isRead = true;
        });
      } catch (_) {}
    }

    // Show full content in bottom sheet
    if (mounted) {
      _showAnnouncementDetail(announcement);
    }
  }

  void _showAnnouncementDetail(AnnouncementModel announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image
              if (announcement.imageUrl != null &&
                  announcement.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    announcement.imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Title
              Text(
                announcement.title ?? '',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                _formatDate(announcement.publishedAt ??
                    announcement.createdAt),
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 12,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 16),

              // Body
              Text(
                announcement.body ?? '',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 15,
                  color: accentColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
          'Announcements',
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
                      Text(_error!,
                          style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 14,
                              color: subTextColor),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadAnnouncements,
                        child: Text('Retry',
                            style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                color: blueButton)),
                      ),
                    ],
                  ),
                )
              : _announcements.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.campaign_outlined,
                      title: 'No Announcements',
                      subtitle: 'No announcements at this time.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      color: accentColor,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _announcements.length +
                            (_isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _announcements.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          return AnnouncementCard(
                            announcement: _announcements[index],
                            onTap: () => _onAnnouncementTap(index),
                          );
                        },
                      ),
                    ),
    );
  }
}
