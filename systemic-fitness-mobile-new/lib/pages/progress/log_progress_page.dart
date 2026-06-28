import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/exercise_model.dart';
import 'package:workout/models/progress_model.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/custom_text_field.dart';

class LogProgressPage extends StatefulWidget {
  final String? exerciseId;
  final String? workoutId;

  const LogProgressPage({super.key, this.exerciseId, this.workoutId});

  @override
  State<LogProgressPage> createState() => _LogProgressPageState();
}

class _LogProgressPageState extends State<LogProgressPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSearching = false;

  List<ExerciseModel> _exercises = [];
  ExerciseModel? _selectedExercise;
  String? _selectedMood;
  List<_SetRow> _sets = [];

  final List<String> _moods = ['great', 'good', 'okay', 'tired', 'bad'];

  @override
  void initState() {
    super.initState();
    _sets.add(_SetRow(setNumber: 1));
    if (widget.exerciseId != null) {
      _fetchExerciseById(widget.exerciseId!);
    } else {
      _fetchExercises();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    for (final s in _sets) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchExerciseById(String id) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getWithRetry(ApiConfig.exerciseById(id));
      final data = response['data'];
      if (data != null && mounted) {
        setState(() {
          _selectedExercise = ExerciseModel.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(
          msg: 'Failed to load exercise.',
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _fetchExercises() async {
    setState(() => _isSearching = true);
    try {
      final response = await ApiService.getWithRetry(ApiConfig.exercises);
      final data = response['data'];
      if (data is List && mounted) {
        setState(() {
          _exercises = data.map((e) => ExerciseModel.fromJson(e)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _addSet() {
    setState(() {
      _sets.add(_SetRow(setNumber: _sets.length + 1));
    });
  }

  void _removeSet(int index) {
    if (_sets.length <= 1) return;
    setState(() {
      _sets[index].dispose();
      _sets.removeAt(index);
      for (int i = 0; i < _sets.length; i++) {
        _sets[i].setNumber = i + 1;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercise == null) {
      Fluttertoast.showToast(
        msg: 'Please select an exercise.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final setsData = _sets.map((s) => {
        'set_number': s.setNumber,
        'reps': int.tryParse(s.repsController.text) ?? 0,
        'weight_kg': double.tryParse(s.weightController.text) ?? 0.0,
        'rpe': int.tryParse(s.rpeController.text),
      }).toList();

      await ApiService.postWithRetry(
        ApiConfig.progressLog,
        body: {
          'exercise_id': _selectedExercise!.id,
          if (widget.workoutId != null) 'workout_id': widget.workoutId,
          'sets': setsData,
          'notes': _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          'mood': _selectedMood,
        },
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Progress logged successfully!',
          backgroundColor: greenButton,
          textColor: Colors.white,
        );
        context.pop();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save progress.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _moodIcon(String mood) {
    switch (mood) {
      case 'great':
        return '😁';
      case 'good':
        return '😊';
      case 'okay':
        return '😐';
      case 'tired':
        return '😴';
      case 'bad':
        return '😞';
      default:
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
          'Log Progress',
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise selector
                    _buildLabel('Exercise'),
                    const SizedBox(height: 8),
                    if (widget.exerciseId != null && _selectedExercise != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedExercise!.name ?? 'Selected Exercise',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                      )
                    else
                      _buildExerciseDropdown(),
                    const SizedBox(height: 20),

                    // Sets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Sets'),
                        TextButton.icon(
                          onPressed: _addSet,
                          icon: Icon(Icons.add, size: 18, color: blueButton),
                          label: Text(
                            'Add Set',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 13,
                              color: blueButton,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._sets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final setRow = entry.value;
                      return _buildSetRow(setRow, index);
                    }),
                    const SizedBox(height: 20),

                    // Mood selector
                    _buildLabel('Mood'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return ChoiceChip(
                          label: Text(
                            '${_moodIcon(mood)} ${mood[0].toUpperCase()}${mood.substring(1)}',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 13,
                              color: isSelected ? Colors.white : accentColor,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: accentColor,
                          backgroundColor: primaryColor,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMood = selected ? mood : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    _buildLabel('Notes'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Catatan opsional tentang sesi anda...',
                      controller: _notesController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    CustomButton(
                      text: 'Save Progress',
                      onPressed: _save,
                      isLoading: _isSaving,
                      color: greenButton,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: Constants.fontsFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: accentColor,
      ),
    );
  }

  Widget _buildExerciseDropdown() {
    final filtered = _searchController.text.isEmpty
        ? _exercises
        : _exercises
            .where((e) =>
                (e.name ?? '').toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();

    return Column(
      children: [
        CustomTextField(
          hint: 'Search exercise...',
          controller: _searchController,
          prefixIcon: Icon(Icons.search, color: subTextColor, size: 20),
          onChanged: (_) => setState(() {}),
        ),
        if (filtered.isNotEmpty && _selectedExercise == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final exercise = filtered[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    exercise.name ?? '',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      color: accentColor,
                    ),
                  ),
                  subtitle: Text(
                    exercise.muscleGroup?.join(', ') ?? '',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedExercise = exercise;
                      _searchController.text = exercise.name ?? '';
                    });
                  },
                );
              },
            ),
          ),
        if (_selectedExercise != null && widget.exerciseId == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected: ${_selectedExercise!.name}',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: greenButton,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedExercise = null;
                      _searchController.clear();
                    });
                  },
                  child: Icon(Icons.close, size: 18, color: subTextColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSetRow(_SetRow setRow, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set ${setRow.setNumber}',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              if (_sets.length > 1)
                GestureDetector(
                  onTap: () => _removeSet(index),
                  child: Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: setRow.repsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Reps'),
                  style: _inputStyle(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: setRow.weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Weight (kg)'),
                  style: _inputStyle(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextFormField(
                  controller: setRow.rpeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('RPE'),
                  style: _inputStyle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: Constants.fontsFamily,
        fontSize: 13,
        color: subTextColor,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle _inputStyle() {
    return TextStyle(
      fontFamily: Constants.fontsFamily,
      fontSize: 14,
      color: accentColor,
    );
  }
}

class _SetRow {
  int setNumber;
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rpeController = TextEditingController();

  _SetRow({required this.setNumber});

  void dispose() {
    repsController.dispose();
    weightController.dispose();
    rpeController.dispose();
  }
}
