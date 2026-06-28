import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: blueButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: group.imageUrl != null && group.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        group.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: SvgPicture.asset(
                            '${Constants.assetsImagePath}group.svg',
                            height: 24,
                            color: blueButton,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        '${Constants.assetsImagePath}group.svg',
                        height: 24,
                        color: blueButton,
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name ?? '',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      group.description!,
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 13,
                        color: subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${group.memberCount ?? 0}${group.maxMembers != null ? '/${group.maxMembers}' : ''} members',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: subTextColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
