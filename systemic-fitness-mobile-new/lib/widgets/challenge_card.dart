import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image or placeholder
            challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty
                ? Image.network(
                    challenge.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.name ?? '',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusBadge(challenge.status),
                    ],
                  ),
                  if (challenge.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      challenge.description!,
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 13,
                        color: subTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 13, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.startDate ?? '—'} — ${challenge.endDate ?? '—'}',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 14, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.participantCount ?? 0}${challenge.maxParticipants != null ? '/${challenge.maxParticipants}' : ''}',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (challenge.isActive && challenge.daysRemaining > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 13, color: greenButton),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.daysRemaining} days remaining',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: greenButton,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: cellColor,
      child: Center(
        child: Icon(
          Icons.emoji_events,
          size: 48,
          color: subTextColor.withOpacity(0.4),
        ),
      ),
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
}
