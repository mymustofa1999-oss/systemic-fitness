import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/workout_model.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  bool _isLoading = true;
  String? _error;
  WorkoutModel? _workout;

  @override
  void initState() {
    super.initState();
    _fetchWorkout();
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
        setState(() {
          _workout = WorkoutModel.fromJson(data);
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

  String _formatType(String? type) {
    if (type == null || type.isEmpty) return 'General';
    return type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ');
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
          'Workout Detail',
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
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? _buildErrorState()
              : _workout == null
                  ? _buildEmptyState()
                  : _buildContent(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 56, color: subTextColor),
          const SizedBox(height: 16),
          Text(
            'Workout not found',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 16,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final workout = _workout!;
    final exercises = workout.exercises ?? [];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout info card
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
                        workout.name ?? 'Untitled Workout',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      if (workout.description != null &&
                          workout.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          workout.description!,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 14,
                            color: subTextColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.category_outlined,
                            _formatType(workout.type),
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.timer_outlined,
                            '${workout.estimatedDurationMin ?? 0} min',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.format_list_numbered,
                            '${exercises.length} exercises',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Exercises section
                Text(
                  'Exercises',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (exercises.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No exercises in this workout',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  )
                else
                  ...exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return _buildExerciseCard(exercise, index);
                  }),
              ],
            ),
          ),
        ),

        // Start workout button
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
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/workouts/${widget.workoutId}/session');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenButton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Workout',
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
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: subTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
    return GestureDetector(
      onTap: () {
        if (exercise.exerciseId != null) {
          context.push('/exercises/${exercise.exerciseId}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Index circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName ?? 'Unknown Exercise',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildExerciseSubtitle(exercise),
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  ),
                  if (exercise.muscleGroup != null &&
                      exercise.muscleGroup!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: exercise.muscleGroup!.map((mg) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: blueButton.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mg,
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 11,
                              color: blueButton,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subTextColor, size: 20),
          ],
        ),
      ),
    );
  }

  String _buildExerciseSubtitle(WorkoutExercise exercise) {
    final parts = <String>[];
    if (exercise.sets != null) parts.add('${exercise.sets} sets');
    if (exercise.reps != null) parts.add('${exercise.reps} reps');
    if (exercise.weightKg != null && exercise.weightKg! > 0) {
      parts.add('${exercise.weightKg} kg');
    }
    if (exercise.restSeconds != null) {
      parts.add('${exercise.restSeconds}s rest');
    }
    return parts.isEmpty ? 'No details' : parts.join(' · ');
  }
}
