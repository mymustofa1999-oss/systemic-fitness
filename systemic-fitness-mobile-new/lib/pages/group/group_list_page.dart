import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/group_model.dart';
import 'package:workout/models/pagination_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/group_card.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<GroupModel> _groups = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
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

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '20',
      };
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.groups,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      final meta = response['meta'];

      setState(() {
        _groups = data.map((e) => GroupModel.fromJson(e)).toList();
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
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.groups,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _groups.addAll(data.map((e) => GroupModel.fromJson(e)));
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _loadGroups();
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
          'My Groups',
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: accentColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  color: subTextColor,
                ),
                prefixIcon:
                    Icon(Icons.search, color: subTextColor, size: 20),
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
                            Text(_error!,
                                style: TextStyle(
                                    fontFamily: Constants.fontsFamily,
                                    fontSize: 14,
                                    color: subTextColor),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _loadGroups,
                              child: Text('Retry',
                                  style: TextStyle(
                                      fontFamily: Constants.fontsFamily,
                                      color: blueButton)),
                            ),
                          ],
                        ),
                      )
                    : _groups.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.group_outlined,
                            title: 'No Groups',
                            subtitle: 'You are not in any groups yet.',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadGroups,
                            color: accentColor,
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _groups.length +
                                  (_isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == _groups.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child:
                                            CircularProgressIndicator()),
                                  );
                                }
                                final group = _groups[index];
                                return GroupCard(
                                  group: group,
                                  onTap: () => context.push(
                                    AppRoutes.groupDetail
                                        .replaceFirst(':id', group.id!),
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
