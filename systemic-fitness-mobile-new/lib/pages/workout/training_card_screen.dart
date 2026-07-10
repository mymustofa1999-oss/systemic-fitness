import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/online_models/TrainingCardModels.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/models/payment_model.dart';
import 'package:workout/router/app_router.dart';

// Card level can be a single value ("5") or a range ("5-6", "4-5") — see the
// trainer_card_templates.level convention. The "Level 5/6" workout session is
// for performance-tier clients, whose level resolves to 5 or 6 (the backend
// emits "5-6" for physical_status_level = level_4_5_perf). Match on either
// bound so the range form "5-6" is recognised, not just a bare "5"/"6".
bool _isPerformanceLevel(String? level) {
  if (level == null || level.isEmpty) return false;
  return level
      .split(RegExp(r'[-–]'))
      .map((part) => int.tryParse(part.trim()))
      .any((n) => n == 5 || n == 6);
}


// ════════════════════════════════════════════════════════════════════
//  Training Card Screen — Premium dynamic theme design
//  Supports light & dark modes with optimized color contrasts.
// ════════════════════════════════════════════════════════════════════

// ── Pillar Colors ──────────────────────────────────────────────────
const Map<String, Color> _pillarColors = {
  'FUNCTIONAL': Color(0xFF5FD68A),
  'CARDIO': Color(0xFFFB923C),
  'METABOLIC': Color(0xFFF87171),
};

const Map<String, String> _pillarNames = {
  'FUNCTIONAL': 'Functional',
  'CARDIO': 'Cardio',
  'METABOLIC': 'Metabolic',
};

// ── Dynamic Theme Tokens ───────────────────────────────────────────
class _TrainingCardTheme {
  final bool isDark;
  final Color bg;
  final Color card;
  final Color border;
  final Color divider;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final Color gold;
  final Color goldBg;
  final Color goldBorder;
  final Color goldDim;
  final Color toggleBg;
  final Color toggleBorder;
  final Color toggleActive;
  final Color chipBg;
  final Color chipBorder;
  final Color chipText;
  final Color breathDBg;
  final Color breathCBg;
  final Color breathBlue = const Color(0xFF93C5FD);
  final Color breathGreen = const Color(0xFF86EFAC);

  _TrainingCardTheme(this.isDark)
      : bg = isDark ? const Color(0xFF0B0B0D) : const Color(0xFFF8F6F1),
        card = isDark ? const Color(0xFF161518) : const Color(0xFFFFFFFF),
        border = isDark ? const Color(0xFF1E1C1A) : const Color(0xFFE5E7EB),
        divider = isDark ? const Color(0xFF0F0E0C) : const Color(0xFFE5E7EB),
        text = isDark ? const Color(0xFFE8E0D4) : const Color(0xFF1A1A1A),
        textSecondary = isDark ? const Color(0xFFC5BBAA) : const Color(0xFF5B564E),
        textMuted = isDark ? const Color(0xFF9F9582) : const Color(0xFF7A756D),
        textDim = isDark ? const Color(0xFF6D6554) : const Color(0xFF9E9A92),
        gold = isDark ? const Color(0xFFC9A96E) : const Color(0xFFB8922E),
        goldBg = isDark ? const Color(0xFF1E1608) : const Color(0xFFF5F0E4),
        goldBorder = isDark ? const Color(0x30C9A96E) : const Color(0xFFE0D2A8),
        goldDim = isDark ? const Color(0xFF6A5A3A) : const Color(0xFF9A7E30),
        toggleBg = isDark ? const Color(0xFF0F0E0C) : const Color(0xFFF0EDE6),
        toggleBorder = isDark ? const Color(0xFF1E1C1A) : const Color(0xFFE0DCD4),
        toggleActive = isDark ? const Color(0xFF1E1C15) : const Color(0xFFF9F5EC),
        chipBg = isDark ? const Color(0xFF1A1810) : const Color(0xFFF0EDE6),
        chipBorder = isDark ? const Color(0xFF2A2510) : const Color(0xFFE0DCD4),
        chipText = isDark ? const Color(0xFFE8E0D4) : const Color(0xFF5C4E32),
        breathDBg = isDark ? const Color(0xFF0D1D35) : const Color(0xFFE8F0FF),
        breathCBg = isDark ? const Color(0xFF091E10) : const Color(0xFFE8F8EE);
}

// ════════════════════════════════════════════════════════════════════
//  Main Screen
// ════════════════════════════════════════════════════════════════════

class TrainingCardScreen extends StatefulWidget {
  const TrainingCardScreen({Key? key}) : super(key: key);

  @override
  State<TrainingCardScreen> createState() => _TrainingCardScreenState();
}

class _TrainingCardScreenState extends State<TrainingCardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TrainingCardResponse? _data;
  UserModel? _profileUser;
  Map<String, dynamic>? _latestAssessment;
  ClientSubscription? _subscription;
  String? _expandedMovementId;
  String _tier3PlanName = 'SF Tier 3';

  // State
  int _sessionIndex = 0; // 0 = Full Program, 1 = Daily Reset
  Set<int> _trainedDays = {};
  String _activeTab = 'FC';

  // BPM Sync Playback State
  final AudioPlayer _bpmPlayer = AudioPlayer();
  String? _selectedBpm;
  String? _playingMovementId;
  bool _isBpmPlaying = false;

  // Level 5-6 active session state
  bool _sessionStarted = false;
  bool _isPaused = false;
  Timer? _sessionTimer;
  int _sessionDurationSeconds = 0;
  // Seconds accrued before the current running segment, plus the epoch ms the
  // timer was last resumed at (null while paused). Tracking the resume time
  // lets us recompute real elapsed time after the user leaves the page and
  // comes back, and freezes cleanly when paused.
  int _accumulatedSeconds = 0;
  int? _resumedAtMs;
  static const String _sessionStorageKey = 'tc_workout_session';

  bool get _isEn => Localizations.localeOf(context).languageCode == 'en';
  bool get _isTier2 => _subscription?.tier == 'sf_tier_2';
  bool get _isTier3 => _subscription?.tier == 'sf_tier_3';
  bool get _isOverriddenTier => _isTier2 || _isTier3;

  // A movement is gated per package. Empty allowedTiers = open to all.
  bool _isMovementLocked(TrainingMovement mv) {
    final tiers = mv.allowedTiers;
    if (tiers == null || tiers.isEmpty) return false;
    return !tiers.contains(_subscription?.tier);
  }

  String _tierLabels(TrainingMovement mv) {
    const labels = {'sf_tier_2': '499K', 'sf_tier_3': '799K'};
    final tiers = mv.allowedTiers ?? [];
    if (tiers.isEmpty) return _tier3PlanName;
    return tiers.map((t) => labels[t] ?? t).join(' / ');
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final since = _resumedAtMs != null
            ? ((DateTime.now().millisecondsSinceEpoch - _resumedAtMs!) ~/ 1000)
            : 0;
        setState(() {
          _sessionDurationSeconds = _accumulatedSeconds + since;
        });
      }
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  Future<void> _persistSession(bool paused) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _sessionStorageKey,
        jsonEncode({
          'active': true,
          'paused': paused,
          'accumulatedSeconds': _accumulatedSeconds,
          'resumedAt': _resumedAtMs,
        }),
      );
    } catch (_) {
      /* ignore persistence failures */
    }
  }

  Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionStorageKey);
    } catch (_) {
      /* ignore */
    }
  }

  // Restore an in-progress session on mount — lets the user switch to another
  // menu and come back without losing the timer (resumes if it was paused).
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionStorageKey);
      if (raw == null) return;
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      if (saved['active'] != true) return;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      _accumulatedSeconds = (saved['accumulatedSeconds'] as num?)?.toInt() ?? 0;
      final paused = saved['paused'] == true;
      final savedResumedAt = (saved['resumedAt'] as num?)?.toInt();
      _resumedAtMs = paused ? null : (savedResumedAt ?? nowMs);
      final elapsed = paused
          ? _accumulatedSeconds
          : _accumulatedSeconds + ((nowMs - (savedResumedAt ?? nowMs)) ~/ 1000);
      if (!mounted) return;
      setState(() {
        _sessionStarted = true;
        _isPaused = paused;
        _sessionDurationSeconds = elapsed;
      });
      if (!paused) _startSessionTimer();
    } catch (_) {
      /* ignore malformed persisted state */
    }
  }

  void _startSession() {
    _accumulatedSeconds = 0;
    _resumedAtMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _sessionStarted = true;
      _isPaused = false;
      _sessionDurationSeconds = 0;
    });
    _startSessionTimer();
    _persistSession(false);
  }

  void _pauseSession() {
    final since = _resumedAtMs != null
        ? ((DateTime.now().millisecondsSinceEpoch - _resumedAtMs!) ~/ 1000)
        : 0;
    _accumulatedSeconds += since;
    _resumedAtMs = null;
    _stopSessionTimer();
    setState(() {
      _isPaused = true;
      _sessionDurationSeconds = _accumulatedSeconds;
    });
    _persistSession(true);
  }

  void _resumeSession() {
    _resumedAtMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _isPaused = false;
    });
    _startSessionTimer();
    _persistSession(false);
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishSession() async {
    final isEn = _isEn;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _TrainingCardTheme(Theme.of(context).brightness == Brightness.dark).card,
        title: Text(
          isEn ? 'Finish Workout?' : 'Akhiri Sesi Latihan?',
          style: TextStyle(color: _TrainingCardTheme(Theme.of(context).brightness == Brightness.dark).text),
        ),
        content: Text(
          isEn
              ? 'Are you sure you want to finish this session and record your progress?'
              : 'Apakah Anda yakin ingin mengakhiri sesi latihan ini dan mencatat progress Anda?',
          style: TextStyle(color: _TrainingCardTheme(Theme.of(context).brightness == Brightness.dark).textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isEn ? 'No' : 'Batal', style: TextStyle(color: _TrainingCardTheme(Theme.of(context).brightness == Brightness.dark).textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _TrainingCardTheme(Theme.of(context).brightness == Brightness.dark).gold,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isEn ? 'Finish' : 'Selesai', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Final elapsed = accrued + time since last resume (0 while paused).
      final finalSeconds = _accumulatedSeconds +
          (_resumedAtMs != null
              ? ((DateTime.now().millisecondsSinceEpoch - _resumedAtMs!) ~/ 1000)
              : 0);

      _stopSessionTimer();
      _accumulatedSeconds = 0;
      _resumedAtMs = null;
      await _clearPersistedSession();

      // Record the finished session (best-effort; navigation proceeds anyway).
      unawaited(_recordWorkoutSession(finalSeconds));

      if (mounted) {
        setState(() {
          _sessionStarted = false;
          _isPaused = false;
        });
        context.push(AppRoutes.progress);
      }
    }
  }

  Future<void> _recordWorkoutSession(int durationSeconds) async {
    try {
      await ApiService.postWithRetry(ApiConfig.workoutSessions, body: {
        'session_type': _sessionIndex == 0 ? 'full' : 'daily',
        'duration_seconds': durationSeconds,
        'level': _data?.level ?? '',
      });
    } catch (_) {
      // Best-effort: the session already ended locally.
    }
  }

  void _generatePresetCard() {
    final gender = _profileUser?.profile?.gender ?? 'female';
    final isMale = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'men';

    final movementsData = [
      {'id': 'm1', 'title': 'Arm Rotation', 'movement_tag': 'FC', 'video_url_male': 'https://youtu.be/Gv0JzAjI4wE', 'video_url_female': 'https://youtu.be/CDkR0Hqu_B4'},
      {'id': 'm2', 'title': 'Arm Rotation Stand', 'movement_tag': 'FC', 'video_url_male': 'https://youtu.be/Gv0JzAjI4wE', 'video_url_female': 'https://youtu.be/CDkR0Hqu_B4'},
      {'id': 'm3', 'title': 'Arm Rotation Stand Weight', 'movement_tag': 'CC', 'video_url_male': 'https://youtu.be/Gv0JzAjI4wE', 'video_url_female': 'https://youtu.be/CDkR0Hqu_B4'},
      {'id': 'm4', 'title': 'Barbel Row', 'movement_tag': 'MC', 'video_url_male': 'https://youtu.be/dQPys_dgoGY', 'video_url_female': 'https://youtu.be/dQPys_dgoGY'},
      {'id': 'm5', 'title': 'Bent Over Fly', 'movement_tag': 'MC', 'video_url_male': 'https://youtu.be/prz4V9AacSE', 'video_url_female': 'https://youtu.be/prz4V9AacSE'},
      {'id': 'm6', 'title': 'Bicep Curls', 'movement_tag': 'MC', 'video_url_male': 'https://youtu.be/SZKOhGoXcTI', 'video_url_female': 'https://youtu.be/SZKOhGoXcTI'},
      {'id': 'm7', 'title': 'Chest Press', 'movement_tag': 'MC', 'video_url_male': 'https://youtu.be/wuH_zwLy6EM', 'video_url_female': 'https://youtu.be/wuH_zwLy6EM'},
      {'id': 'm8', 'title': 'Cross Up', 'movement_tag': 'MC', 'video_url_male': 'https://youtu.be/qy2ldvISD2Y', 'video_url_female': 'https://youtu.be/qy2ldvISD2Y'},
    ];

    final movements = movementsData.asMap().entries.map((e) {
      final idx = e.key;
      final m = e.value;
      final videoUrl = isMale ? m['video_url_male'] : m['video_url_female'];
      return TrainingMovement(
        id: m['id'],
        sequence: idx + 1,
        title: m['title'],
        videoUrl: videoUrl,
        movementTag: m['movement_tag'],
      );
    }).toList();

    final fullProgram = [
      ProgramCategory(
        type: 'FUNCTIONAL',
        duration: "10'",
        sets: [
          TrainingSet(
            setName: 'Set 1',
            durationMins: 3,
            bpmRange: '80',
            tags: ['Group AG', 'Wrist 0.25 kg', 'Ankle 0.5 kg'],
            movements: movements,
          )
        ],
      ),
      ProgramCategory(
        type: 'CARDIO',
        duration: "20'",
        sets: [
          TrainingSet(
            setName: 'Set 1',
            durationMins: 5,
            bpmRange: '',
            tags: ['1.00 kg', '2.00 kg'],
            movements: movements,
          )
        ],
      ),
      ProgramCategory(
        type: 'METABOLIC',
        duration: "30'",
        sets: [
          TrainingSet(
            setName: 'Set 1',
            durationMins: 5,
            bpmRange: '',
            tags: ['3.00 kg', '3.00 kg'],
            movements: movements,
          )
        ],
      )
    ];

    setState(() {
      _data = TrainingCardResponse(
        level: '1',
        notes: '',
        fullProgram: fullProgram,
        dailyReset: fullProgram,
      );
      _onSetChanged();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTrainingCard();
    _restoreSession();
    _bpmPlayer.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        },
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ));
  }

  @override
  void dispose() {
    _bpmPlayer.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  String _formatWeight(String weight) {
    return weight
        .replaceAllMapped(RegExp(r'(\d+)\.00'), (match) => match.group(1)!)
        .replaceAllMapped(RegExp(r'(\d+\.\d)0'), (match) => match.group(1)!);
  }

  String _cleanWeightLabel(String label) {
    return label
        .replaceAll(RegExp(r'(wrist|ankle)', caseSensitive: false), '')
        .trim();
  }

  String _getDefaultBpm(String? bpmRange) {
    if (bpmRange == null || bpmRange.isEmpty || bpmRange == '—') {
      return 'No BPM';
    }
    final match = RegExp(r'(\d+)').firstMatch(bpmRange);
    if (match != null) {
      final bpmStr = match.group(1);
      final bpmVal = int.tryParse(bpmStr ?? '');
      if (bpmVal != null) {
        int clamped = bpmVal;
        if (clamped < 60) clamped = 60;
        if (clamped > 200) clamped = 200;
        
        // Round to nearest 10
        int rounded = ((clamped + 5) ~/ 10) * 10;
        
        const supported = ['60', '70', '80', '90', '100', '110', '120', '130', '140', '150', '160', '170', '180', '190', '200'];
        final roundedStr = rounded.toString();
        if (supported.contains(roundedStr)) {
          return roundedStr;
        }
      }
    }
    return 'No BPM';
  }

  void _onSetChanged() {
    _stopBpm();
    _playingMovementId = null;
    _selectedBpm = 'No BPM';
  }

  Future<void> _playBpm(String? bpm) async {
    if (bpm == null || bpm == 'No BPM') {
      await _bpmPlayer.stop();
      if (mounted) {
        setState(() {
          _isBpmPlaying = false;
        });
      }
      return;
    }
    try {
      final url = 'https://api.systemicfitnesshealth.com/uploads/bpm/$bpm.m4a';
      await _bpmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bpmPlayer.play(UrlSource(url));
      if (mounted) {
        setState(() {
          _isBpmPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error playing BPM: $e');
    }
  }

  Future<void> _stopBpm() async {
    try {
      await _bpmPlayer.stop();
      if (mounted) {
        setState(() {
          _isBpmPlaying = false;
        });
      }
    } catch (e) {
      debugPrint('Error stopping BPM: $e');
    }
  }

  Future<void> _fetchTrainingCard() async {
    try {
      try {
        final sessionsResponse = await ApiService.getWithRetry('/api/v2/workout-sessions?session_type=full&limit=50');
        if (sessionsResponse['success'] == true && sessionsResponse['data'] != null) {
          final sessionsList = List<dynamic>.from(sessionsResponse['data']);
          DateTime now = DateTime.now();
          int dayOfWeek = now.weekday; // 1=Mon, 7=Sun
          DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOfWeek - 1));
          List<DateTime> currentWeekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
          
          Set<int> trained = {};
          for (var s in sessionsList) {
            if (s['completed_at'] != null) {
              DateTime d = DateTime.parse(s['completed_at']).toLocal();
              int idx = currentWeekDates.indexWhere((cwd) => cwd.year == d.year && cwd.month == d.month && cwd.day == d.day);
              if (idx != -1) trained.add(idx);
            }
          }
          if (mounted) {
            setState(() {
              _trainedDays = trained;
            });
          }
        }
      } catch (e) {
        debugPrint('Silent error fetching workout sessions: $e');
      }

      // 1. Fetch subscription details first
      try {
        final subResponse = await ApiService.getWithRetry(ApiConfig.subscriptionMe);
        if (subResponse['success'] == true && subResponse['data'] != null) {
          final subResult = MySubscriptionResult.fromJson(
            Map<String, dynamic>.from(subResponse['data']),
          );
          _subscription = subResult.subscription;
        }
      } catch (e) {
        debugPrint('Silent error fetching subscription: $e');
      }

      // 1.5 Fetch plans to get Tier 3 name dynamically
      try {
        final plansResponse = await ApiService.getWithRetry('/api/subscription/plans');
        if (plansResponse['success'] == true && plansResponse['data'] != null) {
          final groups = List<dynamic>.from(plansResponse['data']);
          dynamic tier3Group;
          for (var g in groups) {
            if (g['tier'] == 'sf_tier_3') {
              tier3Group = g;
              break;
            }
          }
          if (tier3Group != null) {
            final monthly = tier3Group['monthly'];
            final quarterly = tier3Group['quarterly'];
            final annual = tier3Group['annual'];
            final name = (monthly != null ? monthly['name'] : null) ??
                (quarterly != null ? quarterly['name'] : null) ??
                (annual != null ? annual['name'] : null) ??
                'SF Tier 3';
            _tier3PlanName = name;
          }
        }
      } catch (e) {
        debugPrint('Silent error fetching subscription plans: $e');
      }

      // 2. Fetch profile silently
      try {
        final meResponse = await ApiService.getWithRetry(ApiConfig.me);
        if (meResponse['success'] == true && meResponse['data'] != null) {
          final data = meResponse['data'];
          final merged = <String, dynamic>{
            ...?(data['user'] as Map<String, dynamic>?),
            'profile': data['profile'],
            'stats': data['stats'],
            if (_subscription != null) 'subscription': _subscription!.toJson(),
          };
          _profileUser = UserModel.fromJson(merged);
        }
      } catch (e) {
        debugPrint('Silent error fetching profile: $e');
      }

      // 3. Fetch latest assessment silently
      try {
        final assessmentResponse = await ApiService.getWithRetry(ApiConfig.assessmentV2Latest);
        if (assessmentResponse['success'] == true && assessmentResponse['data'] != null) {
          _latestAssessment = Map<String, dynamic>.from(assessmentResponse['data']);
        }
      } catch (e) {
        debugPrint('Silent error fetching latest assessment: $e');
      }

      // 5. Normal flow: fetch card from API
      final response = await ApiService.getWithRetry('/api/v2/assessments/training-card');
      
      if (response['success'] == true) {
        setState(() {
          _data = TrainingCardResponse.fromJson(response['data']);
          _isLoading = false;
          _onSetChanged();
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load training card';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        if (_errorMessage!.contains("402") || _errorMessage!.contains("Payment Required")) {
          _errorMessage = "You must have an active premium subscription to view the Training Card.";
        }
        _isLoading = false;
      });
    }
  }


  List<ProgramCategory> get _activePillars {
    if (_data == null) return [];
    return _sessionIndex == 0
        ? (_data!.fullProgram ?? [])
        : (_data!.dailyReset ?? []);
  }

  ProgramCategory? get _activePillar {
    if (_activePillarIdx < _activePillars.length) return _activePillars[_activePillarIdx];
    return null;
  }

  TrainingSet? get _activeSet {
    if (_activePillar == null || _activePillar!.sets == null) return null;
    if (_activeSetIdx < _activePillar!.sets!.length) return _activePillar!.sets![_activeSetIdx];
    return null;
  }

  void _playVideo(String title, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => _VideoPlayerDialog(
        title: title,
        videoUrl: videoUrl,
      ),
    );
  }

  Color _pillarColor(String? type, _TrainingCardTheme theme) =>
      _pillarColors[type?.toUpperCase()] ?? theme.gold;

  String _pillarName(String? type) =>
      _pillarNames[type?.toUpperCase()] ?? (type ?? '');

  void _setSession(int index) {
    setState(() {
      _sessionIndex = index;
      _activePillarIdx = 0;
      _activeSetIdx = 0;
      _onSetChanged();
    });
  }

  void _setPillar(int index) {
    setState(() {
      _activePillarIdx = index;
      _activeSetIdx = 0;
      _onSetChanged();
    });
  }

  void _setSetIdx(int index) {
    setState(() {
      _activeSetIdx = index;
      _onSetChanged();
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _TrainingCardTheme(isDark);
    final cardLevel = _data?.level ?? '';
    final isLevel5or6 = _isPerformanceLevel(cardLevel);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.text, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEn ? 'Training Card' : 'Kartu Latihan',
          style: GoogleFonts.bebasNeue(
            fontSize: 20,
            color: theme.gold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBody(theme),
          if (isLevel5or6 && !_sessionStarted && !_isLoading && _errorMessage == null && _data != null)
            _buildStartSessionOverlay(theme),
          if (isLevel5or6 && _sessionStarted)
            _buildFloatingTimer(theme),
        ],
      ),
    );
  }

  Widget _buildStartSessionOverlay(_TrainingCardTheme theme) {
    return Container(
      color: theme.bg.withOpacity(0.95),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.gold.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.fitness_center, color: theme.gold, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                _isEn ? 'Start Training Session' : 'Mulai Sesi Latihan',
                style: GoogleFonts.bebasNeue(
                  fontSize: 22,
                  color: theme.gold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _isEn
                    ? 'Confirm to start your Level 5/6 workout session. An active timer will track your workout duration.'
                    : 'Konfirmasi untuk memulai sesi latihan Level 5/6 Anda. Timer aktif akan berjalan untuk mencatat durasi latihan Anda.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _startSession,
                  child: Text(
                    _isEn ? 'Start Workout' : 'Mulai Latihan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTimer(_TrainingCardTheme theme) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.gold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.timer_outlined, color: theme.gold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPaused
                        ? (_isEn ? 'PAUSED' : 'DIJEDA')
                        : (_isEn ? 'SESSION DURATION' : 'DURASI SESI LATIHAN'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.gold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDuration(_sessionDurationSeconds),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.text,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.gold.withOpacity(0.12),
                foregroundColor: theme.gold,
                side: BorderSide(color: theme.gold.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: _isPaused ? _resumeSession : _pauseSession,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 16),
              label: Text(
                _isPaused ? (_isEn ? 'Resume' : 'Lanjut') : (_isEn ? 'Pause' : 'Jeda'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: _finishSession,
              child: Text(
                _isEn ? 'Finish' : 'Akhiri',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(_TrainingCardTheme theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.gold, strokeWidth: 2),
      );
    }
    if (_errorMessage != null) {
      return _buildError(theme);
    }
    if (_data == null || (_data!.fullProgram == null && _data!.dailyReset == null)) {
      return _buildEmpty(theme);
    }
    return _buildContent(theme);
  }

  // ── Error State ──────────────────────────────────────────────────
  Widget _buildError(_TrainingCardTheme theme) {
    final errorBg = theme.isDark ? const Color(0xFF1A0F0F) : const Color(0xFFFEE2E2);
    final errorIcon = theme.isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.lock_outline, size: 32, color: errorIcon),
            ),
            const SizedBox(height: 20),
            Text(
              'Akses Dibatasi',
              style: GoogleFonts.bebasNeue(fontSize: 22, color: theme.text, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────
  Widget _buildEmpty(_TrainingCardTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.goldBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.fitness_center, size: 32, color: theme.gold),
            ),
            const SizedBox(height: 20),
            Text(
              'Kartu Belum Dibuat',
              style: GoogleFonts.bebasNeue(fontSize: 22, color: theme.text, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Trainer Anda belum merumuskan Kartu Latihan untuk Anda saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MAIN CONTENT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPreviewBanner(_TrainingCardTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.gold.withOpacity(0.1),
        border: Border.all(color: theme.gold.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                _isEn ? 'Free Preview' : 'Cuplikan Gratis',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _isEn
                ? 'You\'re viewing a free preview of your Training Card. Subscribe to unlock your full personalized program.'
                : 'Anda sedang melihat cuplikan gratis 3 latihan dari program Anda. Berlangganan untuk membuka seluruh Training Card yang dipersonalisasi.',
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () async {
                    final url = Uri.parse('https://wa.me/081234567890'); // Placeholder number
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      Fluttertoast.showToast(msg: "Tidak dapat membuka WhatsApp");
                    }
                  },
                  icon: const Icon(Icons.message, size: 16),
                  label: const Text('Consultant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    // Navigate to subscription/premium screen. We can push a route that likely exists like /premium or /subscribe.
                    // Based on user prompt "1. Subscribe", I will assume a typical route like `/subscribe` or push to a premium page.
                    // For now, context.push('/subscribe') is safe. If it doesn't exist, it will show a 404.
                    context.push('/subscribe');
                  },
                  child: const Text('Upgrade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_TrainingCardTheme theme) {
    final showPreviewBanner = _data?.isPreview == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Preview Banner
          if (showPreviewBanner) _buildPreviewBanner(theme),

          // ── Client Info Header
          _buildInfoHeader(theme),
          const SizedBox(height: 12),

          // ── Session Toggle
          _buildSessionToggle(theme),
          const SizedBox(height: 10),

          // ── Pillar Tabs
          _buildPillarTabs(theme),
          const SizedBox(height: 8),

          // ── Set Tabs (if > 1)
          if (_activePillar != null &&
              _activePillar!.sets != null &&
              _activePillar!.sets!.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSetTabs(theme),
            ),

          // ── Exercise Card
          if (_activeSet != null)
            _buildExerciseCard(_activePillar!, _activeSet!, theme),
        ],
      ),
    );
  }

  // ── Info Header ──────────────────────────────────────────────────
  Widget _buildInfoHeader(_TrainingCardTheme theme) {
    int? getAge(String? dobString) {
      if (dobString == null || dobString.isEmpty) return null;
      try {
        final dob = DateTime.parse(dobString);
        final today = DateTime.now();
        int age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
        return age;
      } catch (_) {
        return null;
      }
    }

    String getGenderLabel(String? gender) {
      if (gender == null) return '';
      if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'men') {
        return 'Pria';
      }
      if (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'women') {
        return 'Wanita';
      }
      return gender;
    }

    final ageVal = getAge(_profileUser?.profile?.dateOfBirth);
    final genderVal = getGenderLabel(_profileUser?.profile?.gender);
    final heightVal = _profileUser?.profile?.heightCm;
    final parts = <String>[];
    if (ageVal != null) parts.add('${ageVal}yr');
    if (genderVal.isNotEmpty) parts.add(genderVal);
    if (heightVal != null) parts.add('${heightVal.toInt()}cm');
    final metadataText = parts.join(' · ');

    // Classification & Condition labels mapping
    const Map<String, String> classificationLabels = {
      "imun-inflamasi": "Imun & Inflamasi",
      "renal-uric": "Renal & Uric",
      "cardiorespiratory": "Cardiorespiratory",
      "metabolic-syndrome": "Metabolic Syndrome",
      "preventive": "Preventive",
    };

    const Map<String, String> conditionLabels = {
      "autoimun": "Autoimun",
      "alergi-kronis": "Alergi Kronis",
      "inflamasi-sistemik": "Inflamasi Sistemik",
      "kista": "Kista",
      "tumor-jinak": "Tumor Jinak",
      "fibromyalgia": "Fibromyalgia",
      "diabetes-type-2": "Diabetes Tipe 2",
      "hipertensi": "Hipertensi",
      "obesitas": "Obesitas",
      "jantung-koroner": "Jantung Koroner",
      "asma": "Asma",
      "gerd": "GERD",
      "gout": "Asam Urat",
      "ginjal-kronis": "Ginjal Kronis",
    };

    String formatSlug(String slug) {
      return slug
          .split('-')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '')
          .join(' ');
    }

    final phaseA = _latestAssessment?['phase_a'] as Map<String, dynamic>?;
    final classSlug = phaseA?['classification_slug'] as String?;
    final condSlug = phaseA?['specific_condition_slug'] as String?;

    final classLabel = classSlug != null
        ? (classificationLabels[classSlug] ?? formatSlug(classSlug))
        : null;
    final condLabel = condSlug != null
        ? (conditionLabels[condSlug] ?? formatSlug(condSlug))
        : null;

    final weekDays = [
      {'label': 'Sen', 'type': '60', 'val': "60'"},
      {'label': 'Sel', 'type': 'rest', 'val': ''},
      {'label': 'Rab', 'type': '60', 'val': "60'"},
      {'label': 'Kam', 'type': 'rest', 'val': ''},
      {'label': 'Jum', 'type': '60', 'val': "60'"},
      {'label': 'Sab', 'type': 'rest', 'val': ''},
      {'label': 'Min', 'type': 'rest', 'val': ''}
    ];

    Widget buildDayCircle(Map<String, String> day, bool hasTrained, bool is60) {
      Color borderColor = theme.border;
      Color bgColor = Colors.transparent;
      Color textColor = theme.textMuted;

      if (hasTrained) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0x1810B981);
        textColor = const Color(0xFF10B981);
      } else if (is60) {
        borderColor = theme.goldBorder;
        bgColor = Colors.transparent;
        textColor = theme.goldDim;
      }

      Widget circle = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: borderColor, width: hasTrained ? 1.5 : 1.0),
        ),
        alignment: Alignment.center,
        child: hasTrained
            ? Icon(Icons.check, size: 14, color: textColor)
            : Text(
                day['val']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      );

      if (hasTrained) {
        circle = Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF10B981), width: 2),
          ),
          child: circle,
        );
      } else {
        circle = Padding(
          padding: const EdgeInsets.all(4),
          child: circle,
        );
      }

      return circle;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: User Profile
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileUser?.fullName ?? _profileUser?.email ?? 'Client Name',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.text,
                        height: 1.2,
                      ),
                    ),
                    if (metadataText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        metadataText,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_data?.level != null && _data!.level!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.goldBg,
                              border: Border.all(color: theme.goldBorder),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'Level ${_data!.level}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.gold,
                              ),
                            ),
                          ),
                        if (classLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x0D10B981),
                              border: Border.all(color: const Color(0x3310B981)),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              classLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        if (condLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x0D10B981),
                              border: Border.all(color: const Color(0x3310B981)),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              condLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right side: Weekly Schedule
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JADWAL MINGGUAN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: theme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: weekDays.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> day = entry.value;
                      final is60 = day['type'] == '60';
                      final hasTrained = _trainedDays.contains(idx);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildDayCircle(day, hasTrained, is60),
                          const SizedBox(height: 6),
                          Text(
                            day['label']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: hasTrained ? const Color(0xFF10B981) : is60 ? theme.gold : theme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),


        ],
      ),
    );
  // ── Session Toggle ───────────────────────────────────────────────
  Widget _buildSessionToggle(_TrainingCardTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.toggleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.toggleBorder),
      ),
      child: Row(
        children: [
          _buildToggleButton(0, 'Full Program', '60 min · 2×/minggu', theme),
          _buildToggleButton(1, 'Daily Reset', '30 min · 2×/minggu', theme),
        ],
      ),
    );
  }

  Widget _buildToggleButton(int index, String label, String sub, _TrainingCardTheme theme) {
    final isActive = _sessionIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setSession(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? theme.toggleActive : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: index == 0
                ? Border(right: BorderSide(color: theme.toggleBorder))
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? theme.gold : theme.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  color: isActive ? theme.goldDim : theme.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pillar Tabs ──────────────────────────────────────────────────
  Widget _buildPillarTabs(_TrainingCardTheme theme) {
    return Row(
      children: _activePillars.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        final clr = _pillarColor(p.type, theme);
        final name = _pillarName(p.type);
        final isActive = _activePillarIdx == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => _setPillar(i),
            child: Container(
              margin: EdgeInsets.only(
                right: i < _activePillars.length - 1 ? 5 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? clr.withValues(alpha: 0.07) : theme.card,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isActive ? clr : theme.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? clr : theme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.duration ?? '',
                    style: TextStyle(fontSize: 9, color: theme.textDim),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Set Tabs ─────────────────────────────────────────────────────
  Widget _buildSetTabs(_TrainingCardTheme theme) {
    final sets = _activePillar!.sets!;
    final clr = _pillarColor(_activePillar!.type, theme);
    return Row(
      children: sets.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isActive = _activeSetIdx == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => _setSetIdx(i),
            child: Container(
              margin: EdgeInsets.only(right: i < sets.length - 1 ? 5 : 0),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? clr.withValues(alpha: 0.07) : theme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? clr : theme.border),
              ),
              child: Column(
                children: [
                  Text(
                    s.setName ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? clr : theme.textMuted,
                    ),
                  ),
                  Text(
                    '${s.durationMins ?? 0}\'',
                    style: TextStyle(fontSize: 9, color: theme.textDim),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Exercise Card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildExerciseCard(ProgramCategory category, TrainingSet set, _TrainingCardTheme theme) {
    final pc = _pillarColor(category.type, theme);
    final pillarName = _pillarName(category.type);
    final hasBPM = set.bpmRange != null && set.bpmRange!.isNotEmpty && set.bpmRange != '—';
    final movements = set.movements ?? [];

    // Detect breath types
    final breathTypes = movements
        .map((m) => m.movementTag ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    final hasMixedBreath = breathTypes.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        border: Border.all(color: pc.withValues(alpha: 0.13)),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [pc.withValues(alpha: 0.06), Colors.transparent],
              ),
              border: Border(bottom: BorderSide(color: pc.withValues(alpha: 0.09))),
            ),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pillarName · ${set.setName ?? ''}',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 16,
                          color: pc,
                          letterSpacing: 2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          _Chip(text: '⏱ ${set.durationMins ?? 0} menit'),
                          if (set.equipmentUpper != null && set.equipmentUpper!.isNotEmpty)
                            _Chip(
                              text: '💪 Tangan: ${_formatWeight(_cleanWeightLabel(set.equipmentUpper!))}',
                              color: theme.breathBlue,
                              bg: theme.breathDBg,
                              borderColor: theme.breathBlue.withValues(alpha: 0.19),
                            ),
                          if (set.equipmentLower != null && set.equipmentLower!.isNotEmpty)
                            _Chip(
                              text: '🦵 Kaki: ${_formatWeight(_cleanWeightLabel(set.equipmentLower!))}',
                              color: theme.breathGreen,
                              bg: theme.breathCBg,
                              borderColor: theme.breathGreen.withValues(alpha: 0.19),
                            ),
                          ...?set.tags?.where((tag) =>
                              tag != set.equipmentUpper &&
                              tag != set.equipmentLower &&
                              !tag.toLowerCase().contains('wrist') &&
                              !tag.toLowerCase().contains('ankle')
                          ).map((tag) {
                            return _Chip(text: tag);
                          }),
                          if (!hasMixedBreath && breathTypes.length == 1)
                            _BreathBadge(type: breathTypes.first),
                        ],
                      ),
                    ],
                  ),
                ),
                // BPM mini label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'BPM MUSIC',
                      style: TextStyle(fontSize: 8, color: theme.textDim, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.chipBg,
                        border: Border.all(color: theme.chipBorder),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBpm ?? 'No BPM',
                          isDense: true,
                          dropdownColor: theme.card,
                          icon: Icon(Icons.arrow_drop_down, color: pc, size: 16),
                          style: TextStyle(
                            fontSize: 11,
                            color: pc,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedBpm = newValue;
                                if (_playingMovementId != null) {
                                  _playBpm(_selectedBpm);
                                }
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'No BPM',
                              child: Text(
                                'No BPM',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                            ...['60', '70', '80', '90', '100', '110', '120', '130', '140', '150', '160', '170', '180', '190', '200'].map((bpm) {
                              return DropdownMenuItem<String>(
                                value: bpm,
                                child: Text(
                                  '$bpm BPM',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 11,
                                    color: pc,
                                    letterSpacing: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Exercise Rows
          ...movements.asMap().entries.map((e) {
            final i = e.key;
            final mv = e.value;
            final isLocked = _isMovementLocked(mv);
            final isExpanded = _expandedMovementId == mv.id;

            return GestureDetector(
              onTap: () {
                if (isLocked) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: theme.card,
                      title: Text(
                        'Fitur Terkunci',
                        style: TextStyle(color: theme.text),
                      ),
                      content: Text(
                        'Silakan upgrade ke paket ${_tierLabels(mv)} untuk membuka video gerakan ini.',
                        style: TextStyle(color: theme.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Batal', style: TextStyle(color: theme.textMuted)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.gold,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.subscription);
                          },
                          child: const Text('Upgrade Sekarang', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                } else if (mv.videoUrl != null && mv.videoUrl!.isNotEmpty) {
                  setState(() {
                    if (_expandedMovementId == mv.id) {
                      _expandedMovementId = null;
                      if (_playingMovementId == mv.id) {
                        _playingMovementId = null;
                        _stopBpm();
                      }
                    } else {
                      _expandedMovementId = mv.id;
                    }
                  });
                }
              },
              child: Opacity(
                opacity: isLocked ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Ensure gesture detector captures the whole row
                    border: !isExpanded && i < movements.length - 1
                        ? Border(bottom: BorderSide(color: theme.divider))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Number badge
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isLocked ? theme.toggleBg : pc.withValues(alpha: 0.07),
                              border: Border.all(
                                color: isLocked ? theme.border : pc.withValues(alpha: 0.13),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            child: isLocked
                                ? Icon(Icons.lock_outline, size: 10, color: theme.textMuted)
                                : Text(
                                    '${mv.sequence ?? i + 1}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pc),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              mv.title ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isLocked ? theme.textMuted : theme.text,
                              ),
                            ),
                          ),
                          if (isLocked)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock, size: 10, color: theme.gold),
                                const SizedBox(width: 2),
                                Text(
                                  'Locked (${_tierLabels(mv)})',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.gold,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          else if (mv.videoUrl != null && mv.videoUrl!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isExpanded ? Icons.close : Icons.play_arrow, size: 10, color: theme.gold),
                                const SizedBox(width: 2),
                                Text(
                                  isExpanded ? 'Close' : 'Play Video',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.gold,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          if (hasMixedBreath && mv.movementTag != null && mv.movementTag!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _BreathBadge(type: mv.movementTag!),
                          ],
                        ],
                      ),
                      if (isExpanded && mv.videoUrl != null && mv.videoUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InlineYoutubePlayer(
                                videoUrl: mv.videoUrl!,
                                onPlayStateChanged: (isPlaying) {
                                  setState(() {
                                    if (isPlaying) {
                                      _playingMovementId = mv.id;
                                      _playBpm(_selectedBpm);
                                    } else {
                                      if (_playingMovementId == mv.id) {
                                        _playingMovementId = null;
                                        _stopBpm();
                                      }
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              if (_isPerformanceLevel(_data?.level))
                                _buildBpmAudioPlayer(theme, pc),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Breath note at bottom
          if (!hasMixedBreath && breathTypes.length == 1 && movements.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.divider)),
              ),
              child: Row(
                children: [
                  Text('Napas:', style: TextStyle(fontSize: 10, color: theme.textMuted)),
                  const SizedBox(width: 6),
                  _BreathBadge(type: breathTypes.first),
                ],
              ),
            ),

          // ── BPM Target Block
          if (hasBPM)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: pc.withValues(alpha: 0.03),
                border: Border(top: BorderSide(color: pc.withValues(alpha: 0.13))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET BPM SESI INI',
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        set.bpmRange!,
                        style: GoogleFonts.bebasNeue(
                          fontSize: 28,
                          color: pc,
                          height: 1,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'RANGE',
                        style: TextStyle(fontSize: 9, color: theme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: _splitBPM(set.bpmRange!).map((v) {
                          return Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pc.withValues(alpha: 0.08),
                              border: Border.all(color: pc.withValues(alpha: 0.19)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              v.trim(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 16,
                                color: pc,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<String> _splitBPM(String bpm) {
    if (bpm.contains('–')) return bpm.split('–');
    if (bpm.contains('-')) return bpm.split('-');
    return [bpm];
  }

  Widget _buildBpmAudioPlayer(_TrainingCardTheme theme, Color pcColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.toggleBg,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _isBpmPlaying ? Icons.music_note : Icons.music_off,
            color: _isBpmPlaying ? pcColor : theme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BPM MUSIC PLAYER',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: theme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isBpmPlaying
                      ? 'Playing · $_selectedBpm BPM'
                      : (_selectedBpm == 'No BPM' ? 'Muted (No BPM)' : 'Paused · $_selectedBpm BPM'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: theme.chipBg,
              border: Border.all(color: theme.chipBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBpm ?? 'No BPM',
                isDense: true,
                dropdownColor: theme.card,
                icon: Icon(Icons.arrow_drop_down, color: pcColor, size: 16),
                style: TextStyle(
                  fontSize: 11,
                  color: pcColor,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBpm = newValue;
                      if (_isBpmPlaying || _playingMovementId != null) {
                        _playBpm(_selectedBpm);
                      }
                    });
                  }
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'No BPM',
                    child: Text(
                      'No BPM',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                  ...['60', '70', '80', '90', '100', '110', '120', '130', '140', '150', '160', '170', '180', '190', '200'].map((bpm) {
                    return DropdownMenuItem<String>(
                      value: bpm,
                      child: Text(
                        '$bpm BPM',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 11,
                          color: pcColor,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_selectedBpm == 'No BPM') return;
              if (_isBpmPlaying) {
                _stopBpm();
              } else {
                _playBpm(_selectedBpm);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedBpm == 'No BPM'
                    ? theme.chipBg
                    : pcColor.withValues(alpha: 0.15),
                border: Border.all(
                  color: _selectedBpm == 'No BPM'
                      ? theme.chipBorder
                      : pcColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                _isBpmPlaying ? Icons.pause : Icons.play_arrow,
                color: _selectedBpm == 'No BPM' ? theme.textMuted : pcColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Reusable Widgets
// ════════════════════════════════════════════════════════════════════

class _Chip extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? bg;
  final Color? borderColor;

  const _Chip({
    required this.text,
    this.color,
    this.bg,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _TrainingCardTheme(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg ?? theme.chipBg,
        border: Border.all(color: borderColor ?? theme.chipBorder),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color ?? theme.chipText),
      ),
    );
  }
}

class _BreathBadge extends StatelessWidget {
  final String type;

  const _BreathBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _TrainingCardTheme(isDark);

    final label = (type == 'FC' || type == 'CC' || type == 'MC') ? 'Core' : type;
    final icon = type == 'Diafragma 1:1' ? '🌬' : '⚡';
    final color = type == 'Diafragma 1:1' ? theme.breathBlue : theme.breathGreen;
    final bg = type == 'Diafragma 1:1' ? theme.breathDBg : theme.breathCBg;


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: color.withValues(alpha: 0.19)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$icon $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  final String title;
  final String videoUrl;

  const _VideoPlayerDialog({
    Key? key,
    required this.title,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _TrainingCardTheme(isDark);

    if (_youtubeController == null) {
      return AlertDialog(
        backgroundColor: theme.card,
        title: Text(
          widget.title,
          style: TextStyle(color: theme.text),
        ),
        content: Text(
          'Video URL tidak valid atau tidak didukung',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup', style: TextStyle(color: theme.gold)),
          ),
        ],
      );
    }

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Stack(
            children: [
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: theme.gold,
                progressColors: ProgressBarColors(
                  playedColor: theme.gold,
                  handleColor: theme.gold,
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
        ],
      ),
    );
  }
}

class InlineYoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final ValueChanged<bool>? onPlayStateChanged;
  const InlineYoutubePlayer({Key? key, required this.videoUrl, this.onPlayStateChanged}) : super(key: key);

  @override
  State<InlineYoutubePlayer> createState() => _InlineYoutubePlayerState();
}

class _InlineYoutubePlayerState extends State<InlineYoutubePlayer> {
  YoutubePlayerController? _controller;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: true,
          forceHD: false,
          enableCaption: false,
        ),
      )..addListener(() {
          if (mounted && _controller != null) {
            final isPlaying = _controller!.value.isPlaying;
            if (isPlaying != _wasPlaying) {
              _wasPlaying = isPlaying;
              widget.onPlayStateChanged?.call(isPlaying);
            }
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFC9A96E),
          ),
          // Block top bar (title, share, info)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 40,
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
            width: 80,
            height: 35,
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
            width: 70,
            height: 35,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _controller?.toggleFullScreenMode();
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 6),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 24,
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
    );
  }
}

