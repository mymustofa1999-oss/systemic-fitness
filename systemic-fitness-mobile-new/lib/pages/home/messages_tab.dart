import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/Widgets.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/message_model.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await ApiService.getWithRetry(ApiConfig.conversations);
      if (!mounted) return;
      final dataList = response['data'] as List? ?? [];
      setState(() {
        _conversations =
            dataList.map((e) => Conversation.fromJson(e)).toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load conversations';
        _isLoading = false;
      });
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double textMargin = SizeConfig.safeBlockHorizontal! * 3.5;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgDarkWhite,
      child: _isLoading
          ? Center(child: getProgressDialog())
          : _error != null
              ? _buildError(textMargin)
              : _conversations.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      color: accentColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: textMargin / 2),
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          return _buildConversationTile(
                              _conversations[index], textMargin);
                        },
                      ),
                    ),
    );
  }

  Widget _buildConversationTile(
      Conversation conversation, double textMargin) {
    final hasUnread = (conversation.unreadCount ?? 0) > 0;
    final displayName = conversation.name ?? 'Unknown';
    final lastMsg = conversation.lastMessage;

    String? avatarUrl;
    if (conversation.members != null && conversation.members!.isNotEmpty) {
      avatarUrl = conversation.members!.first.avatarUrl;
    }

    double avatarSize = ConstantWidget.getScreenPercentSize(context, 5.5);

    return InkWell(
      onTap: () {
        final id = conversation.id;
        if (id != null) {
          context.push('/messages/$id');
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: textMargin / 2,
          vertical: ConstantWidget.getScreenPercentSize(context, 0.5),
        ),
        child: ConstantWidget.getShadowWidget(
          radius: ConstantWidget.getScreenPercentSize(context, 1.5),
          widget: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ConstantWidget.getWidthPercentSize(context, 3),
              vertical: ConstantWidget.getScreenPercentSize(context, 1.5),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  height: avatarSize,
                  width: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cellColor,
                    image: avatarUrl != null && avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Center(
                          child: ConstantWidget.getTextWidget(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            subTextColor,
                            TextAlign.center,
                            FontWeight.w600,
                            ConstantWidget.getPercentSize(avatarSize, 40),
                          ),
                        )
                      : null,
                ),
                SizedBox(
                    width:
                        ConstantWidget.getWidthPercentSize(context, 3)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ConstantWidget.getCustomText(
                              displayName,
                              textColor,
                              1,
                              TextAlign.start,
                              hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              ConstantWidget.getScreenPercentSize(
                                  context, 1.8),
                            ),
                          ),
                          ConstantWidget.getTextWidget(
                            _formatTime(lastMsg?.createdAt ??
                                conversation.updatedAt),
                            hasUnread ? blueButton : subTextColor,
                            TextAlign.end,
                            FontWeight.w400,
                            ConstantWidget.getScreenPercentSize(
                                context, 1.4),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 0.5),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ConstantWidget.getCustomText(
                              lastMsg?.content ?? 'No messages yet',
                              hasUnread ? textColor : subTextColor,
                              1,
                              TextAlign.start,
                              hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              ConstantWidget.getScreenPercentSize(
                                  context, 1.5),
                            ),
                          ),
                          if (hasUnread) ...[
                            SizedBox(
                                width:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 2)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 1.8),
                                vertical:
                                    ConstantWidget.getScreenPercentSize(
                                        context, 0.3),
                              ),
                              decoration: getDefaultDecoration(
                                bgColor: blueButton,
                                radius:
                                    ConstantWidget.getScreenPercentSize(
                                        context, 1.2),
                              ),
                              child: ConstantWidget.getTextWidget(
                                '${conversation.unreadCount}',
                                Colors.white,
                                TextAlign.center,
                                FontWeight.w600,
                                ConstantWidget.getScreenPercentSize(
                                    context, 1.3),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(double textMargin) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(textMargin * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: subTextColor),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getTextWidget(
              _error ?? 'Something went wrong',
              subTextColor,
              TextAlign.center,
              FontWeight.w400,
              ConstantWidget.getScreenPercentSize(context, 2),
            ),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getButtonWidget(
              context,
              'Retry',
              accentColor,
              _loadConversations,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: subTextColor.withOpacity(0.4)),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2)),
            ConstantWidget.getTextWidget(
              'No conversations yet',
              textColor,
              TextAlign.center,
              FontWeight.w600,
              ConstantWidget.getScreenPercentSize(context, 2.2),
            ),
            SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 1)),
            ConstantWidget.getTextWidget(
              'Start a conversation with your coach',
              subTextColor,
              TextAlign.center,
              FontWeight.w400,
              ConstantWidget.getScreenPercentSize(context, 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
