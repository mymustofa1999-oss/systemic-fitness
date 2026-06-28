import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/group_model.dart';
import 'package:workout/widgets/loading_widget.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  GroupModel? _group;
  List<GroupMember> _members = [];
  bool _isLoading = true;
  String? _error;

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
      final results = await Future.wait([
        ApiService.getWithRetry(ApiConfig.groupById(widget.groupId)),
        ApiService.getWithRetry(ApiConfig.groupMembers(widget.groupId)),
      ]);

      final groupData = results[0]['data'];
      final membersData = results[1]['data'] as List? ?? [];

      setState(() {
        _group =
            groupData != null ? GroupModel.fromJson(groupData) : null;
        _members =
            membersData.map((e) => GroupMember.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          _group?.name ?? 'Group Detail',
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
              : _group == null
                  ? Center(
                      child: Text('Group not found',
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
                          _buildMembersList(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    final g = _group!;
    return Column(
      children: [
        // Group image
        if (g.imageUrl != null && g.imageUrl!.isNotEmpty)
          Image.network(
            g.imageUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
          )
        else
          _buildPlaceholderImage(),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                g.name ?? '',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              if (g.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  g.description!,
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 14,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: subTextColor),
                  const SizedBox(width: 6),
                  Text(
                    '${g.memberCount ?? _members.length}${g.maxMembers != null ? ' / ${g.maxMembers}' : ''} members',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: cellColor,
      child: Center(
        child: Icon(Icons.group,
            size: 64, color: subTextColor.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildMembersList() {
    if (_members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No members yet.',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 14,
            color: subTextColor,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members',
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
            itemCount: _members.length,
            separatorBuilder: (_, __) => Container(
              height: 0.5,
              color: borderColor,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            itemBuilder: (context, index) {
              final member = _members[index];
              return _buildMemberTile(member);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cellColor,
            backgroundImage: member.avatarUrl != null &&
                    member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child:
                member.avatarUrl == null || member.avatarUrl!.isEmpty
                    ? Icon(Icons.person, size: 22, color: subTextColor)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName ?? member.email ?? '—',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
                if (member.email != null &&
                    member.fullName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.email!,
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (member.role != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: member.role == 'admin'
                    ? blueButton.withOpacity(0.1)
                    : cellColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.role!,
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: member.role == 'admin'
                      ? blueButton
                      : subTextColor,
                ),
              ),
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
