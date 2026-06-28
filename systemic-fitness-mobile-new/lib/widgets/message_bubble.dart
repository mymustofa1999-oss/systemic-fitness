import 'package:flutter/material.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String? senderName;
  final String? time;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    this.senderName,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? accentColor : primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (senderName != null && !isMe) ...[
                    Text(
                      senderName!,
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: blueButton,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    content,
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 15,
                      color: isMe ? Colors.white : accentColor,
                      height: 1.35,
                    ),
                  ),
                  if (time != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        time!,
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 11,
                          color: isMe
                              ? Colors.white.withOpacity(0.6)
                              : subTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
