import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/nutrition_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/empty_state_widget.dart';
import 'package:workout/widgets/loading_widget.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isLoading = true;
  String? _error;
  DailyNutrition? _dailyNutrition;
  String? _userId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await PrefData.getUser();
    _userId = user?.id;
    if (_userId == null) return;
    await _fetchDailyNutrition();
  }

  Future<void> _fetchDailyNutrition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await ApiService.getWithRetry(
        ApiConfig.dailyNutrition(_userId!),
        queryParams: {'date': dateStr},
      );
      final data = response['data'];
      if (mounted) {
        setState(() {
          _dailyNutrition = data != null ? DailyNutrition.fromJson(data) : null;
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
          _error = 'Failed to load nutrition data.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchDailyNutrition();
    }
  }

  Map<String, List<NutritionLog>> _groupByMealType() {
    final meals = _dailyNutrition?.meals ?? [];
    final grouped = <String, List<NutritionLog>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };
    for (final meal in meals) {
      final type = meal.mealType?.toLowerCase() ?? 'snack';
      if (grouped.containsKey(type)) {
        grouped[type]!.add(meal);
      } else {
        grouped['snack']!.add(meal);
      }
    }
    return grouped;
  }

  String _mealTypeTitle(String type) {
    switch (type) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return type;
    }
  }

  IconData _mealTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.restaurant_outlined;
      case 'dinner':
        return Icons.nightlight_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.fastfood_outlined;
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
          'Nutrition',
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
            icon: Icon(Icons.restaurant_menu, color: accentColor),
            onPressed: () => context.push(AppRoutes.mealPlans),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.logNutrition);
          _fetchDailyNutrition();
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
              onPressed: _fetchDailyNutrition,
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

    final grouped = _groupByMealType();
    final hasAnyMeals = grouped.values.any((list) => list.isNotEmpty);

    return RefreshIndicator(
      onRefresh: _fetchDailyNutrition,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date picker row
          _buildDatePicker(),
          const SizedBox(height: 16),

          // Summary card
          _buildSummaryCard(),
          const SizedBox(height: 20),

          // Meals grouped by type
          if (!hasAnyMeals)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyStateWidget(
                icon: Icons.restaurant,
                title: 'No Meals Logged',
                subtitle: 'Tap + to log your first meal for today.',
              ),
            )
          else
            ...grouped.entries.where((e) => e.value.isNotEmpty).map((entry) {
              return _buildMealGroup(entry.key, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: blueButton),
                const SizedBox(width: 8),
                Text(
                  isToday ? 'Today' : DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final dn = _dailyNutrition;
    final totalCal = dn?.totalCalories ?? 0;
    final protein = dn?.totalProteinG ?? 0.0;
    final carbs = dn?.totalCarbsG ?? 0.0;
    final fat = dn?.totalFatG ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$totalCal',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'Calories',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroItem('Protein', '${protein.toStringAsFixed(1)}g', blueButton),
              _buildMacroItem('Carbs', '${carbs.toStringAsFixed(1)}g', greenButton),
              _buildMacroItem('Fat', '${fat.toStringAsFixed(1)}g', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildMealGroup(String mealType, List<NutritionLog> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_mealTypeIcon(mealType), size: 20, color: accentColor),
            const SizedBox(width: 8),
            Text(
              _mealTypeTitle(mealType),
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...meals.map((meal) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meal.foodName ?? 'Unknown food',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 14,
                        color: accentColor,
                      ),
                    ),
                  ),
                  Text(
                    '${meal.calories ?? 0} cal',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
