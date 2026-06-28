import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/custom_text_field.dart';
import 'package:workout/widgets/loading_widget.dart';

class NewConversationPage extends StatefulWidget {
  const NewConversationPage({super.key});

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.getWithRetry(ApiConfig.users);
      final data = response['data'];
      final List<UserModel> users = [];
      if (data is List) {
        for (final item in data) {
          users.add(UserModel.fromJson(item));
        }
      }
      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load users.';
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _users);
    } else {
      setState(() {
        _filteredUsers = _users
            .where((u) =>
                (u.fullName ?? '').toLowerCase().contains(query.toLowerCase()) ||
                (u.email ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _startConversation(UserModel user) async {
    setState(() => _isCreating = true);
    try {
      final response = await ApiService.postWithRetry(
        ApiConfig.messagesDirect,
        body: {'user_id': user.id},
      );
      final data = response['data'];
      final conversationId = data?['id'] ?? data?['conversation_id'];

      if (conversationId != null && mounted) {
        context.go('/messages/$conversationId');
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to create conversation.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
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
          'New Conversation',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              hint: 'Search users...',
              controller: _searchController,
              prefixIcon: Icon(Icons.search, color: subTextColor, size: 20),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchUsers,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found.',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 14,
            color: subTextColor,
          ),
        ),
      );
    }
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filteredUsers.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(
                        (user.fullName ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      )
                    : null,
              ),
              title: Text(
                user.fullName ?? 'Unknown',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                ),
              ),
              subtitle: Text(
                user.email ?? '',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
              onTap: () => _startConversation(user),
            );
          },
        ),
        if (_isCreating)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(child: LoadingWidget()),
          ),
      ],
    );
  }
}
