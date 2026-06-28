import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/models/challenge_model.dart';

class ParticipantTile extends StatelessWidget {
  final int rank;
  final ChallengeParticipant participant;
  final String? goalType;

  const ParticipantTile({
    super.key,
    required this.rank,
    required this.participant,
    this.goalType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              _rankLabel,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: cellColor,
            backgroundImage: participant.avatarUrl != null &&
                    participant.avatarUrl!.isNotEmpty
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null ||
                    participant.avatarUrl!.isEmpty
                ? Icon(Icons.person, size: 20, color: subTextColor)
                : null,
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              participant.fullName ?? participant.userId ?? '—',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Progress value
          Text(
            '${participant.progressValue?.toStringAsFixed(0) ?? '0'}',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          if (goalType != null) ...[
            const SizedBox(width: 4),
            Text(
              goalType!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 11,
                color: subTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _rankLabel {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return subTextColor;
    }
  }
}
