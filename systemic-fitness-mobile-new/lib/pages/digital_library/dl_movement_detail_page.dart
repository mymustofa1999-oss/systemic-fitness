import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/dl_movement_model.dart';
import 'package:workout/models/user_model.dart';

class DLMovementDetailPage extends StatefulWidget {
  final String movementId;

  const DLMovementDetailPage({super.key, required this.movementId});

  @override
  State<DLMovementDetailPage> createState() => _DLMovementDetailPageState();
}

class _DLMovementDetailPageState extends State<DLMovementDetailPage> {
  bool _isLoading = true;
  String? _error;
  DLMovementModel? _movement;
  YoutubePlayerController? _youtubeController;
  String? _userGender;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserGender();
    await _fetchMovement();
  }

  Future<void> _loadUserGender() async {
    try {
      final user = await PrefData.getUser();
      setState(() {
        _userGender = user?.profile?.gender?.toLowerCase();
      });
    } catch (e) {
      // Ignore
    }
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

  Future<void> _fetchMovement() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.digitalLibraryMovementById(widget.movementId),
      );
      final data = response['data'];
      if (data != null) {
        final movement = DLMovementModel.fromJson(data);
        
        // Determine which video to play based on user gender
        String? targetVideoUrl = movement.videoUrlMale;
        if (_userGender == 'female' && movement.videoUrlFemale != null && movement.videoUrlFemale!.isNotEmpty) {
          targetVideoUrl = movement.videoUrlFemale;
        } else if ((targetVideoUrl == null || targetVideoUrl.isEmpty) && movement.videoUrlFemale != null && movement.videoUrlFemale!.isNotEmpty) {
          // Fallback if male video is empty but female is not
          targetVideoUrl = movement.videoUrlFemale;
        }
        
        _initYoutubePlayer(targetVideoUrl);
        
        setState(() {
          _movement = movement;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Movement not found';
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
        _error = 'Failed to load movement';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load movement');
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
          'Movement Detail',
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
              : _movement == null
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
              onPressed: _fetchMovement,
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
            'Movement not found',
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
    final movement = _movement!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final displayName = (isEn && movement.nameEn != null && movement.nameEn!.isNotEmpty) ? movement.nameEn! : movement.name ?? 'Unknown Movement';
    final displayDescription = (isEn && movement.descriptionEn != null && movement.descriptionEn!.isNotEmpty) ? movement.descriptionEn : movement.description;
    final displayInstructions = (isEn && movement.instructionsEn != null && movement.instructionsEn!.isNotEmpty) ? movement.instructionsEn : movement.instructions;

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
          else if (movement.imageUrl != null && movement.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: movement.imageUrl!,
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

          // Name & Description
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
                  displayName,
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                if (displayDescription != null && displayDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    displayDescription,
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
          // Details Block (Body Part, Type, Pattern, Level)
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
                if (movement.bodyPart != null && movement.bodyPart!.isNotEmpty) ...[
                  _buildDetailRow(Icons.accessibility_new, 'Body Part', movement.bodyPart!),
                  const SizedBox(height: 16),
                ],
                if (movement.type != null && movement.type!.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.accessibility,
                    'Type',
                    movement.type == 'sit' ? 'Sit' : (movement.type == 'stand' ? 'Stand' : movement.type!),
                  ),
                  const SizedBox(height: 16),
                ],
                if (movement.pattern != null && movement.pattern!.isNotEmpty) ...[
                  _buildDetailRow(Icons.grid_view, 'Pattern', movement.pattern!),
                  const SizedBox(height: 16),
                ],
                if (movement.level != null) ...[
                  _buildDetailRow(Icons.trending_up, 'Level', 'Level ${movement.level}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          if (displayInstructions != null && displayInstructions.isNotEmpty) ...[
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
                    Localizations.localeOf(context).languageCode == 'en' ? 'Instructions' : 'Instruksi',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...displayInstructions.asMap().entries.map((entry) {
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: subTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
