import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/Widgets.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/pagination_model.dart';
import 'package:workout/models/workout_model.dart';

class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const List<String> _filters = [
    'All',
    'Strength',
    'Cardio',
    'Flexibility'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadWorkouts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadWorkouts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _workouts.clear();
    }

    setState(() {
      _isLoading = refresh || _workouts.isEmpty;
      _error = null;
    });

    try {
      final queryParams = <String, String>{
        'page': '$_currentPage',
        'limit': '20',
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      if (_selectedFilter != 'All') {
        queryParams['type'] = _selectedFilter.toLowerCase();
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.workouts,
        queryParams: queryParams,
      );

      final dataList = response['data'] as List? ?? [];
      final newWorkouts =
          dataList.map((e) => WorkoutModel.fromJson(e)).toList();

      if (response['meta'] != null) {
        final meta = PaginationMeta.fromJson(response['meta']);
        _totalPages = meta.totalPages;
      }

      setState(() {
        if (refresh || _currentPage == 1) {
          _workouts = newWorkouts;
        } else {
          _workouts.addAll(newWorkouts);
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load workouts';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadWorkouts();
  }

  Future<void> _onRefresh() async {
    await _loadWorkouts(refresh: true);
  }

  void _onFilterSelected(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _loadWorkouts(refresh: true);
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _loadWorkouts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double textMargin = SizeConfig.safeBlockHorizontal! * 3.5;
    double searchHeight = ConstantWidget.getScreenPercentSize(context, 6);
    double searchRadius = ConstantWidget.getPercentSize(searchHeight, 25);
    double searchFontSize = ConstantWidget.getPercentSize(searchHeight, 28);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgDarkWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1)),

          // Search bar (template style with shadow widget)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: textMargin),
            child: ConstantWidget.getShadowWidget(
              radius: searchRadius,
              widget: Container(
                height: searchHeight,
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    color: accentColor,
                    fontWeight: FontWeight.w400,
                    fontSize: searchFontSize,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Cari sesi...',
                    hintStyle: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: searchFontSize,
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.search, color: subTextColor),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: subTextColor, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1.5)),

          // Training Card Access Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: textMargin),
            child: ConstantWidget.getButtonWidget(
              context,
              'View My Training Card',
              accentColor,
              () => context.push('/training-card'),
            ),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1.5)),

          // Filter chips (template style)
          SizedBox(
            height: ConstantWidget.getScreenPercentSize(context, 4.5),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: textMargin),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(
                  width: ConstantWidget.getScreenPercentSize(context, 1)),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => _onFilterSelected(filter),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ConstantWidget.getWidthPercentSize(context, 5),
                      vertical:
                          ConstantWidget.getScreenPercentSize(context, 0.8),
                    ),
                    decoration: getDefaultDecoration(
                      bgColor: isSelected ? accentColor : cellColor,
                      radius:
                          ConstantWidget.getScreenPercentSize(context, 2.5),
                    ),
                    child: Center(
                      child: ConstantWidget.getTextWidget(
                        filter,
                        isSelected ? Colors.white : subTextColor,
                        TextAlign.center,
                        FontWeight.w500,
                        ConstantWidget.getScreenPercentSize(context, 1.6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1.5)),

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: getProgressDialog())
                : _error != null
                    ? _buildError(textMargin)
                    : _workouts.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            color: accentColor,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: textMargin / 2),
                              itemCount:
                                  _workouts.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _workouts.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Center(
                                        child: getProgressDialog()),
                                  );
                                }
                                return _buildWorkoutCard(
                                    _workouts[index], index, textMargin);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
      WorkoutModel workout, int index, double textMargin) {
    double cardHeight = ConstantWidget.getScreenPercentSize(context, 10);
    double iconSize = ConstantWidget.getPercentSize(cardHeight, 55);
    double radius = ConstantWidget.getPercentSize(cardHeight, 18);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: ConstantWidget.getScreenPercentSize(context, 0.8),
      ),
      child: ConstantWidget.getShadowWidget(
        radius: radius,
        widget: InkWell(
          onTap: () {
            final id = workout.id;
            if (id != null) {
              context.push('/workouts/$id');
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ConstantWidget.getWidthPercentSize(context, 3),
              vertical: ConstantWidget.getScreenPercentSize(context, 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: getDefaultDecoration(
                    bgColor: getCellColor(index),
                    radius: ConstantWidget.getPercentSize(iconSize, 25),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: textColor,
                      size: ConstantWidget.getPercentSize(iconSize, 50),
                    ),
                  ),
                ),
                SizedBox(
                    width:
                        ConstantWidget.getWidthPercentSize(context, 3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstantWidget.getCustomText(
                        workout.name ?? 'Untitled Workout',
                        textColor,
                        1,
                        TextAlign.start,
                        FontWeight.w600,
                        ConstantWidget.getScreenPercentSize(context, 1.8),
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 0.5),
                      ),
                      Row(
                        children: [
                          if (workout.type != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 2),
                                vertical:
                                    ConstantWidget.getScreenPercentSize(
                                        context, 0.3),
                              ),
                              decoration: getDefaultDecoration(
                                bgColor: getCellColor(index),
                                radius:
                                    ConstantWidget.getScreenPercentSize(
                                        context, 0.8),
                              ),
                              child: ConstantWidget.getTextWidget(
                                workout.type!,
                                subTextColor,
                                TextAlign.start,
                                FontWeight.w500,
                                ConstantWidget.getScreenPercentSize(
                                    context, 1.3),
                              ),
                            ),
                            SizedBox(
                                width:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 2)),
                          ],
                          if (workout.estimatedDurationMin != null)
                            ConstantWidget.getTextWidget(
                              '${workout.estimatedDurationMin} min',
                              subTextColor,
                              TextAlign.start,
                              FontWeight.w400,
                              ConstantWidget.getScreenPercentSize(
                                  context, 1.4),
                            ),
                          if (workout.exercises != null) ...[
                            SizedBox(
                                width:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 2)),
                            ConstantWidget.getTextWidget(
                              '${workout.exercises!.length} exercises',
                              subTextColor,
                              TextAlign.start,
                              FontWeight.w400,
                              ConstantWidget.getScreenPercentSize(
                                  context, 1.4),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.navigate_next,
                  color: textColor,
                  size: ConstantWidget.getScreenPercentSize(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(double textMargin) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(textMargin * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: subTextColor),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getTextWidget(
              _error ?? 'Something went wrong',
              subTextColor,
              TextAlign.center,
              FontWeight.w400,
              ConstantWidget.getScreenPercentSize(context, 2),
            ),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getButtonWidget(
              context,
              'Retry',
              accentColor,
              () => _loadWorkouts(refresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center,
                size: 64, color: subTextColor.withOpacity(0.4)),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getTextWidget(
              'No workouts found',
              textColor,
              TextAlign.center,
              FontWeight.w600,
              ConstantWidget.getScreenPercentSize(context, 2.2),
            ),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 1)),
            ConstantWidget.getTextWidget(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Your workouts will appear here',
              subTextColor,
              TextAlign.center,
              FontWeight.w400,
              ConstantWidget.getScreenPercentSize(context, 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
