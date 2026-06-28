import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/workout_model.dart';

class WorkoutSessionPage extends StatefulWidget {
  final String workoutId;

  const WorkoutSessionPage({super.key, required this.workoutId});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  WorkoutModel? _workout;

  int _currentExerciseIndex = 0;
  bool _showMoodSelector = false;
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  // Per-exercise set data: exerciseIndex → list of set maps
  final Map<int, List<Map<String, dynamic>>> _setData = {};

  // Rest timer
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _fetchWorkout();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.workoutById(widget.workoutId),
      );
      final data = response['data'];
      if (data != null) {
        final workout = WorkoutModel.fromJson(data);
        _initSetData(workout);
        setState(() {
          _workout = workout;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Workout not found';
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
        _error = 'Failed to load workout';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load workout');
    }
  }

  void _initSetData(WorkoutModel workout) {
    final exercises = workout.exercises ?? [];
    for (int i = 0; i < exercises.length; i++) {
      final numSets = exercises[i].sets ?? 3;
      _setData[i] = List.generate(numSets, (setIdx) {
        return {
          'reps': exercises[i].reps ?? 0,
          'weight_kg': exercises[i].weightKg ?? 0.0,
          'rpe': 0,
          'completed': false,
        };
      });
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isResting = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isResting = false;
          _restSecondsRemaining = 0;
        });
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  void _goToNextExercise() {
    final exercises = _workout?.exercises ?? [];
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isResting = false;
      });
      _restTimer?.cancel();
    } else {
      // Last exercise done, show mood selector
      setState(() {
        _showMoodSelector = true;
      });
    }
  }

  void _goToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _isResting = false;
      });
      _restTimer?.cancel();
    }
  }

  Future<void> _completeWorkout() async {
    if (_selectedMood == null) {
      Fluttertoast.showToast(msg: 'Please select how you feel');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final exercises = _workout?.exercises ?? [];
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        final sets = _setData[i] ?? [];
        final completedSets = sets
            .where((s) => s['completed'] == true)
            .toList();

        if (completedSets.isEmpty) continue;

        final setsPayload = completedSets.asMap().entries.map((entry) {
          return {
            'set_number': entry.key + 1,
            'reps': entry.value['reps'],
            'weight_kg': entry.value['weight_kg'],
            'rpe': entry.value['rpe'],
            'completed': true,
          };
        }).toList();

        await ApiService.postWithRetry(
          ApiConfig.progressLog,
          body: {
            'exercise_id': exercise.exerciseId,
            'workout_id': widget.workoutId,
            'sets': setsPayload,
            'notes': _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
            'mood': _selectedMood,
          },
        );
      }

      if (mounted) {
        Fluttertoast.showToast(msg: 'Workout completed!');
        context.pop();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to save progress');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showEndWorkoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End Workout?',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your progress will not be saved if you end now.',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 14,
            color: subTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                color: subTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(
              'End',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
          onPressed: _showEndWorkoutDialog,
        ),
        title: Text(
          _workout?.name ?? 'Workout Session',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showEndWorkoutDialog,
            child: Text(
              'End',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? _buildErrorState()
              : _showMoodSelector
                  ? _buildMoodSelector()
                  : _buildSessionContent(),
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
              onPressed: _fetchWorkout,
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

  Widget _buildSessionContent() {
    final exercises = _workout?.exercises ?? [];
    if (exercises.isEmpty) {
      return Center(
        child: Text(
          'No exercises in this workout',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 16,
            color: subTextColor,
          ),
        ),
      );
    }

    final exercise = exercises[_currentExerciseIndex];
    final sets = _setData[_currentExerciseIndex] ?? [];
    final restSec = exercise.restSeconds ?? 90;

    return Column(
      children: [
        // Progress indicator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${exercises.length}',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentExerciseIndex + 1) / exercises.length,
                    backgroundColor: primaryColor,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF37BD4D)),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name & target
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      Text(
                        exercise.exerciseName ?? 'Unknown Exercise',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTargetChip(
                              'Sets', '${exercise.sets ?? 0}'),
                          const SizedBox(width: 10),
                          _buildTargetChip(
                              'Reps', '${exercise.reps ?? 0}'),
                          const SizedBox(width: 10),
                          _buildTargetChip(
                            'Weight',
                            '${exercise.weightKg ?? 0} kg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rest timer
                if (_isResting) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: blueButton.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: blueButton.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rest Time',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: blueButton,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_restSecondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_restSecondsRemaining % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: blueButton,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _skipRest,
                          child: Text(
                            'Skip Rest',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: blueButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Sets logging
                Text(
                  'Log Sets',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 10),

                ...sets.asMap().entries.map((entry) {
                  final setIdx = entry.key;
                  final setMap = entry.value;
                  return _buildSetRow(setIdx, setMap, restSec);
                }),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (_currentExerciseIndex > 0)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _goToPreviousExercise,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentExerciseIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _goToNextExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentExerciseIndex ==
                                (exercises.length - 1)
                            ? greenButton
                            : accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentExerciseIndex == (exercises.length - 1)
                            ? 'Finish'
                            : 'Next Exercise',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 11,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int setIdx, Map<String, dynamic> setMap, int restSec) {
    final isCompleted = setMap['completed'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? greenButton.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? greenButton.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? greenButton : primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${setIdx + 1}',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? Colors.white : accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Reps input
          _buildMiniInput(
            label: 'Reps',
            value: '${setMap['reps'] ?? 0}',
            onChanged: (val) {
              setState(() {
                setMap['reps'] = int.tryParse(val) ?? 0;
              });
            },
          ),
          const SizedBox(width: 8),

          // Weight input
          _buildMiniInput(
            label: 'kg',
            value: '${setMap['weight_kg'] ?? 0.0}',
            onChanged: (val) {
              setState(() {
                setMap['weight_kg'] = double.tryParse(val) ?? 0.0;
              });
            },
          ),
          const SizedBox(width: 8),

          // RPE input
          _buildMiniInput(
            label: 'RPE',
            value: '${setMap['rpe'] ?? 0}',
            onChanged: (val) {
              final rpe = int.tryParse(val) ?? 0;
              setState(() {
                setMap['rpe'] = rpe.clamp(0, 10);
              });
            },
          ),
          const SizedBox(width: 8),

          // Complete checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                setMap['completed'] = !(setMap['completed'] == true);
              });
              if (setMap['completed'] == true) {
                _startRestTimer(restSec);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? greenButton : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted ? greenButton : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInput({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 10,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 32,
            child: TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                filled: true,
                fillColor: primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'key': 'great', 'emoji': '🔥', 'label': 'Great'},
      {'key': 'good', 'emoji': '😊', 'label': 'Good'},
      {'key': 'okay', 'emoji': '😐', 'label': 'Okay'},
      {'key': 'tired', 'emoji': '😩', 'label': 'Tired'},
      {'key': 'bad', 'emoji': '😵', 'label': 'Bad'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.check_circle,
            color: greenButton,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Workout Complete!',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 16,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Mood chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: moods.map((mood) {
              final isSelected = _selectedMood == mood['key'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood['key'] as String;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accentColor : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Notes field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Notes (optional)',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              color: accentColor,
            ),
            decoration: InputDecoration(
              hintText: 'Bagaimana sesi anda hari ini?',
              hintStyle: TextStyle(
                fontFamily: Constants.fontsFamily,
                color: subTextColor,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Complete button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _completeWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenButton,
                disabledBackgroundColor: greenButton.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save & Complete',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
