import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/program_model.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key});

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  bool _isLoading = true;
  String? _error;
  List<ProgramModel> _programs = [];
  List<ProgramModel> _filteredPrograms = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedDifficulty = 'All';

  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
    _searchController.addListener(_filterPrograms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrograms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.programTemplates,
      );
      final dataList = response['data'] as List?;
      if (dataList != null) {
        setState(() {
          _programs =
              dataList.map((e) => ProgramModel.fromJson(e)).toList();
          _isLoading = false;
        });
        _filterPrograms();
      } else {
        setState(() {
          _programs = [];
          _filteredPrograms = [];
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      setState(() {
        _error = 'Failed to load programs';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load programs');
    }
  }

  void _filterPrograms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPrograms = _programs.where((p) {
        final matchesSearch = query.isEmpty ||
            (p.name?.toLowerCase().contains(query) ?? false) ||
            (p.description?.toLowerCase().contains(query) ?? false);
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            p.difficulty?.toLowerCase() ==
                _selectedDifficulty.toLowerCase();
        return matchesSearch && matchesDifficulty;
      }).toList();
    });
  }

  Color _difficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return greenButton;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return subTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Programs',
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: accentColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search programs...',
                hintStyle: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: subTextColor,
                ),
                prefixIcon: Icon(Icons.search, color: subTextColor, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: subTextColor, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: primaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Difficulty filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _difficulties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final diff = _difficulties[index];
                  final isSelected = _selectedDifficulty == diff;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = diff;
                      });
                      _filterPrograms();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        diff,
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : subTextColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                : _error != null
                    ? _buildErrorState()
                    : _filteredPrograms.isEmpty
                        ? _buildEmptyState()
                        : _buildProgramList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _fetchPrograms,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: blueButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty ||
                      _selectedDifficulty != 'All'
                  ? 'No programs match your search'
                  : 'No programs available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramList() {
    return RefreshIndicator(
      onRefresh: _fetchPrograms,
      color: accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPrograms.length,
        itemBuilder: (context, index) {
          return _buildProgramCard(_filteredPrograms[index]);
        },
      ),
    );
  }

  Widget _buildProgramCard(ProgramModel program) {
    return GestureDetector(
      onTap: () {
        if (program.id != null) {
          context.push('/programs/${program.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.name ?? 'Untitled Program',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                if (program.difficulty != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _difficultyColor(program.difficulty)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      program.difficulty!,
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _difficultyColor(program.difficulty),
                      ),
                    ),
                  ),
              ],
            ),
            if (program.description != null &&
                program.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                program.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 13,
                  color: subTextColor,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildProgramMeta(
                  Icons.calendar_month_outlined,
                  '${program.durationWeeks ?? 0} weeks',
                ),
                const SizedBox(width: 16),
                if (program.goal != null && program.goal!.isNotEmpty)
                  _buildProgramMeta(
                    Icons.flag_outlined,
                    program.goal!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: subTextColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 12,
            color: subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
