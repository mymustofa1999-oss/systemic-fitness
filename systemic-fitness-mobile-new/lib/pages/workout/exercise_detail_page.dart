import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/exercise_model.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailPage({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool _isLoading = true;
  String? _error;
  ExerciseModel? _exercise;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _fetchExercise();
  }

  void _initYoutubePlayer(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return;
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return;
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _fetchExercise() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.exerciseById(widget.exerciseId),
      );
      final data = response['data'];
      if (data != null) {
        final exercise = ExerciseModel.fromJson(data);
        _initYoutubePlayer(exercise.videoUrl);
        setState(() {
          _exercise = exercise;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Exercise not found';
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
        _error = 'Failed to load exercise';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load exercise');
    }
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
          'Exercise Detail',
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
              : _exercise == null
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
              onPressed: _fetchExercise,
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
            'Exercise not found',
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
    final exercise = _exercise!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YouTube Video Player / Thumbnail / Placeholder
          if (_youtubeController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: blueButton,
                    progressColors: ProgressBarColors(
                      playedColor: blueButton,
                      handleColor: blueButton,
                    ),
                  ),
                  // Block top bar (title, share, info)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Block bottom-left corner ("Watch on YouTube")
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: 90,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Block bottom-right corner (YouTube logo / other icons) and add fullscreen button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    width: 80,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _youtubeController?.toggleFullScreenMode();
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 28,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black54,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (exercise.thumbnailUrl != null &&
              exercise.thumbnailUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: exercise.thumbnailUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center,
                        size: 48, color: subTextColor),
                    const SizedBox(height: 8),
                    Text(
                      'No media available',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Name & Difficulty
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name ?? 'Unknown Exercise',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    if (exercise.difficulty != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor(exercise.difficulty)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exercise.difficulty!,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _difficultyColor(exercise.difficulty),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    exercise.description!,
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Equipment & Muscle Groups
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
                // Equipment
                if (exercise.equipment != null &&
                    exercise.equipment!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.sports_gymnastics,
                          size: 18, color: subTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Equipment',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.equipment!,
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Muscle groups
                if (exercise.muscleGroup != null &&
                    exercise.muscleGroup!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.accessibility_new,
                          size: 18, color: subTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Muscle Groups',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercise.muscleGroup!.map((mg) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: blueButton.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mg,
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: blueButton,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          if (exercise.instructions != null &&
              exercise.instructions!.isNotEmpty) ...[
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
                    'Instructions',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...exercise.instructions!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                instruction,
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 14,
                                  color: accentColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
