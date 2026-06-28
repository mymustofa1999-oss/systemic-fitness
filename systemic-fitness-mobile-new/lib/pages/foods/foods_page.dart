import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  List<Map<String, dynamic>> _foods = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final queryParams = <String, String>{};
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final response = await ApiService.getWithRetry(
        ApiConfig.foods,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _foods = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data makanan';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _loadFoods();
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
          'Makanan',
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
                hintText: 'Cari makanan...',
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
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
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 56, color: subTextColor),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                fontFamily:
                                    Constants.fontsFamily,
                                fontSize: 14,
                                color: subTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _loadFoods,
                              child: Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  fontFamily:
                                      Constants.fontsFamily,
                                  color: blueButton,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _foods.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.restaurant_outlined,
                            title: 'Tidak Ada Makanan',
                            subtitle:
                                'Tidak ada makanan yang ditemukan.',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadFoods,
                            color: accentColor,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _foods.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final food = _foods[index];
                                final name =
                                    (food['name'] ?? '-')
                                        .toString();
                                final calories =
                                    food['calories'] ??
                                        food['calories_per_serving'] ??
                                        0;
                                final protein =
                                    food['protein'] ??
                                        food['protein_per_serving'] ??
                                        0;
                                final carbs = food['carbs'] ??
                                    food['carbs_per_serving'] ??
                                    0;
                                final fat = food['fat'] ??
                                    food['fat_per_serving'] ??
                                    0;
                                final servingUnit =
                                    (food['serving_unit'] ??
                                            food['unit'] ??
                                            '')
                                        .toString();

                                return Container(
                                  padding:
                                      const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        getCellColor(index),
                                    borderRadius:
                                        BorderRadius.circular(
                                            14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style:
                                                  TextStyle(
                                                fontFamily:
                                                    Constants
                                                        .fontsFamily,
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color:
                                                    accentColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: accentColor,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          20),
                                            ),
                                            child: Text(
                                              '$calories kkal',
                                              style:
                                                  TextStyle(
                                                fontFamily:
                                                    Constants
                                                        .fontsFamily,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                                color: Colors
                                                    .white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (servingUnit
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          'Per sajian ($servingUnit)',
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
                                      const SizedBox(
                                          height: 10),
                                      Row(
                                        children: [
                                          _buildNutrientChip(
                                            'Protein',
                                            '${protein}g',
                                            Colors.blue,
                                          ),
                                          const SizedBox(
                                              width: 8),
                                          _buildNutrientChip(
                                            'Karbo',
                                            '${carbs}g',
                                            Colors.orange,
                                          ),
                                          const SizedBox(
                                              width: 8),
                                          _buildNutrientChip(
                                            'Lemak',
                                            '${fat}g',
                                            Colors.red,
                                          ),
                                        ],
                                      ),
                                    ],
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

  Widget _buildNutrientChip(
      String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 10,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
