import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';
import 'package:workout/router/app_router.dart';

class DigitalLibraryPage extends StatefulWidget {
  const DigitalLibraryPage({super.key});

  @override
  State<DigitalLibraryPage> createState() => _DigitalLibraryPageState();
}

class _DigitalLibraryPageState extends State<DigitalLibraryPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  // Movement list state (ketika user tap sebuah category)
  String? _selectedCategoryCode;
  String? _selectedCategoryName;
  List<Map<String, dynamic>> _movements = [];
  bool _isLoadingMovements = false;
  String? _movementError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.digitalLibraryCategories,
      );
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _categories = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat kategori';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMovements(String categoryCode) async {
    setState(() {
      _isLoadingMovements = true;
      _movementError = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.digitalLibraryMovements,
        queryParams: {'category': categoryCode},
      );
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _movements = data.cast<Map<String, dynamic>>();
        _isLoadingMovements = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _movementError = e.message;
        _isLoadingMovements = false;
      });
    } catch (e) {
      setState(() {
        _movementError = 'Gagal memuat movements';
        _isLoadingMovements = false;
      });
    }
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    final code = (category['code'] ?? '').toString();
    final name = (category['name'] ?? '').toString();
    setState(() {
      _selectedCategoryCode = code;
      _selectedCategoryName = name;
      _movements = [];
    });
    _loadMovements(code);
  }

  void _onBackToCategories() {
    setState(() {
      _selectedCategoryCode = null;
      _selectedCategoryName = null;
      _movements = [];
      _movementError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showMovements = _selectedCategoryCode != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            if (showMovements) {
              _onBackToCategories();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          showMovements
              ? _selectedCategoryName ?? 'Movements'
              : 'Digital Library',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: showMovements ? _buildMovementList() : _buildCategoryList(),
    );
  }

  Widget _buildCategoryList() {
    if (_isLoading) return const LoadingWidget();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: subTextColor),
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
              onPressed: _loadCategories,
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
      );
    }

    if (_categories.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.library_books_outlined,
        title: 'Belum Ada Kategori',
        subtitle: 'Kategori digital library belum tersedia.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final name = (category['name'] ?? '-').toString();
          final description =
              (category['description'] ?? '').toString();
          final code = (category['code'] ?? '').toString();

          return Material(
            color: getCellColor(index),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _onCategoryTap(category),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
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
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                          if (code.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                code.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: subTextColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: subTextColor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovementList() {
    if (_isLoadingMovements) return const LoadingWidget();

    if (_movementError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _movementError!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  _loadMovements(_selectedCategoryCode!),
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
      );
    }

    if (_movements.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.fitness_center_outlined,
        title: 'Belum Ada Movement',
        subtitle: 'Movement di kategori ini belum tersedia.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMovements(_selectedCategoryCode!),
      color: accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _movements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final movement = _movements[index];
          final localeStr = Localizations.localeOf(context).languageCode;
          final name = (localeStr == 'en' && movement['name_en'] != null && movement['name_en'].toString().isNotEmpty)
              ? movement['name_en'].toString()
              : (movement['name'] ?? '-').toString();
          final level = (movement['level'] ?? '').toString();
          final imageUrl = (movement['image_url'] ?? '').toString();

          final id = (movement['id'] ?? '').toString();

          return Material(
            color: getCellColor(index),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (id.isNotEmpty) {
                  context.push(AppRoutes.dlMovementDetail.replaceAll(':id', id));
                }
              },
              child: Row(
                children: [
                // Image / placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: SizedBox(
                    width: 90,
                    height: 80,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: subTextColor.withOpacity(0.1),
                              child: Icon(
                                Icons.fitness_center,
                                color: subTextColor,
                                size: 28,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.5),
                            child: Icon(
                              Icons.fitness_center,
                              color: subTextColor,
                              size: 28,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                        if (level.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.6),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: TextStyle(
                                fontFamily:
                                    Constants.fontsFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
