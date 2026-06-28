import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/challenge_model.dart';
import 'package:workout/models/pagination_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/challenge_card.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '20',
      };
      if (_selectedFilter != 'All') {
        queryParams['status'] = _selectedFilter.toLowerCase();
      }
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.challenges,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      final meta = response['meta'];

      setState(() {
        _challenges =
            data.map((e) => ChallengeModel.fromJson(e)).toList();
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
      final queryParams = <String, String>{
        'page': '$nextPage',
        'limit': '20',
      };
      if (_selectedFilter != 'All') {
        queryParams['status'] = _selectedFilter.toLowerCase();
      }
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.challenges,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _challenges
            .addAll(data.map((e) => ChallengeModel.fromJson(e)));
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onFilterSelected(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _loadChallenges();
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _loadChallenges();
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
          'Challenges',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: accentColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search challenges...',
                hintStyle: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  color: subTextColor,
                ),
                prefixIcon: Icon(Icons.search, color: subTextColor, size: 20),
                filled: true,
                fillColor: primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filter tabs
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => _onFilterSelected(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : subTextColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
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
                              onPressed: _loadChallenges,
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  color: blueButton,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _challenges.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.emoji_events_outlined,
                            title: 'No Challenges',
                            subtitle: 'No challenges available yet.',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadChallenges,
                            color: accentColor,
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _challenges.length +
                                  (_isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                if (index == _challenges.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child:
                                            CircularProgressIndicator()),
                                  );
                                }
                                final challenge = _challenges[index];
                                return ChallengeCard(
                                  challenge: challenge,
                                  onTap: () => context.push(
                                    AppRoutes.challengeDetail
                                        .replaceFirst(':id', challenge.id!),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
