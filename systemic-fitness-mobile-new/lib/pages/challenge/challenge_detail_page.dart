import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/challenge_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/participant_tile.dart';

class ChallengeDetailPage extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailPage({super.key, required this.challengeId});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  ChallengeModel? _challenge;
  List<ChallengeParticipant> _participants = [];
  bool _isLoading = true;
  String? _error;
  bool _isJoined = false;
  bool _isJoining = false;
  String? _currentUserId;
  double? _myProgress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await PrefData.getUser();
      _currentUserId = user?.id;

      final results = await Future.wait([
        ApiService.getWithRetry(
            ApiConfig.challengeById(widget.challengeId)),
        ApiService.getWithRetry(
            ApiConfig.challengeParticipants(widget.challengeId)),
      ]);

      final challengeData = results[0]['data'];
      final participantsData = results[1]['data'] as List? ?? [];

      setState(() {
        _challenge = challengeData != null
            ? ChallengeModel.fromJson(challengeData)
            : null;
        _participants = participantsData
            .map((e) => ChallengeParticipant.fromJson(e))
            .toList();
        _isJoined =
            _participants.any((p) => p.userId == _currentUserId);

        if (_isJoined && _currentUserId != null) {
          final myParticipant = _participants
              .where((p) => p.userId == _currentUserId)
              .firstOrNull;
          _myProgress = myParticipant?.progressValue;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinChallenge() async {
    setState(() => _isJoining = true);
    try {
      await ApiService.postWithRetry(
          ApiConfig.joinChallenge(widget.challengeId));
      Fluttertoast.showToast(
        msg: 'Joined challenge!',
        backgroundColor: greenButton,
        textColor: Colors.white,
      );
      await _loadData();
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Failed to join challenge.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _leaveChallenge() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Leave Challenge',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to leave this challenge?',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            color: subTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    color: subTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Leave',
                style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isJoining = true);
    try {
      await ApiService.postWithRetry(
          ApiConfig.leaveChallenge(widget.challengeId));
      Fluttertoast.showToast(
        msg: 'Left challenge.',
        backgroundColor: greenButton,
        textColor: Colors.white,
      );
      await _loadData();
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Failed to leave challenge.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
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
          'Challenge Detail',
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
          ? const LoadingWidget()
          : _error != null
              ? _buildError()
              : _challenge == null
                  ? Center(
                      child: Text('Challenge not found',
                          style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              color: subTextColor)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: accentColor,
                      child: ListView(
                        children: [
                          _buildHeader(),
                          _buildInfo(),
                          _buildActionButtons(),
                          _buildLeaderboard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    return _challenge!.imageUrl != null &&
            _challenge!.imageUrl!.isNotEmpty
        ? Image.network(
            _challenge!.imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderBanner(),
          )
        : _buildPlaceholderBanner();
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      color: cellColor,
      child: Center(
        child: Icon(Icons.emoji_events,
            size: 64, color: subTextColor.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildInfo() {
    final c = _challenge!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.name ?? '',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
              _statusBadge(c.status),
            ],
          ),
          if (c.description != null) ...[
            const SizedBox(height: 10),
            Text(
              c.description!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today,
              '${c.startDate ?? '—'} — ${c.endDate ?? '—'}'),
          const SizedBox(height: 8),
          _infoRow(Icons.flag,
              'Goal: ${c.goalValue?.toStringAsFixed(0) ?? '—'} ${c.goalType ?? ''}'),
          const SizedBox(height: 8),
          _infoRow(Icons.people,
              '${c.participantCount ?? 0}${c.maxParticipants != null ? ' / ${c.maxParticipants}' : ''} participants'),
          if (c.isActive && c.daysRemaining > 0) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.timer_outlined,
                '${c.daysRemaining} days remaining'),
          ],
          if (_isJoined && _myProgress != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.trending_up,
                'My progress: ${_myProgress!.toStringAsFixed(0)} ${c.goalType ?? ''}'),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: subTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String? status) {
    Color badgeColor;
    switch (status) {
      case 'active':
        badgeColor = greenButton;
        break;
      case 'completed':
        badgeColor = blueButton;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = subTextColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        (status ?? 'draft').toUpperCase(),
        style: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final c = _challenge!;
    if (!c.isActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Join or Leave button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isJoining
                  ? null
                  : (_isJoined ? _leaveChallenge : _joinChallenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoined ? Colors.red : greenButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isJoining
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _isJoined ? 'Leave Challenge' : 'Join Challenge',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Update Progress button (only if joined)
          if (_isJoined) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  await context.push(
                    AppRoutes.challengeProgress
                        .replaceFirst(':id', widget.challengeId),
                  );
                  _loadData();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: blueButton),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Update My Progress',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blueButton,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_participants.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _participants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ParticipantTile(
                rank: index + 1,
                participant: _participants[index],
                goalType: _challenge?.goalType,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: subTextColor),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              color: subTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadData,
            child: Text('Retry',
                style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    color: blueButton)),
          ),
        ],
      ),
    );
  }
}
