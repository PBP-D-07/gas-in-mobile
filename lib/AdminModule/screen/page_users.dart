import 'package:flutter/material.dart';
import 'package:gas_in/AdminModule/screen/users_api.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PageUsers extends StatefulWidget {
  const PageUsers({super.key});

  @override
  State<PageUsers> createState() => _PageUsersState();
}

class _PageUsersState extends State<PageUsers> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> adminUsers = [];
  List<Map<String, dynamic>> regularUsers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please login first as admin';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedUsers = await UserService.getAllUsers(request);
      setState(() {
        users = fetchedUsers
            .map(
              (user) => {
                'username': user.username,
                'role': user.role,
                'registered': user.formattedDate,
              },
            )
            .toList();

        // Pisahkan admin dan user
        adminUsers = users.where((u) => u['role'] == 'Admin').toList();
        regularUsers = users.where((u) => u['role'] == 'User').toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load users: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _promoteUser(String username) async {
    final request = context.read<CookieRequest>();

    try {
      final result = await UserService.promoteUser(request, username);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '$username promoted to Admin'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _demoteUser(String username) async {
    final request = context.read<CookieRequest>();

    try {
      final result = await UserService.demoteUser(request, username);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '$username demoted to User'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header with Back Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2D3436),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Back to Admin Dashboard',
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Color(0xFF6C5CE7),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF2D3436)),
                  onPressed: _loadUsers,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Overview Cards
          if (!isLoading && errorMessage == null)
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Total Users Card
                  Expanded(
                    child: _buildOverviewCard(
                      title: 'Total Users',
                      count: users.length,
                      color: const Color(0xFFE3F2FD),
                      borderColor: Colors.blueAccent,
                      icon: Icons.people,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Admin Users Card
                  Expanded(
                    child: _buildOverviewCard(
                      title: 'Admin Users',
                      count: adminUsers.length,
                      color: const Color(0xFFFFEBEE),
                      borderColor: Colors.redAccent,
                      icon: Icons.admin_panel_settings,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Regular Users Card
                  Expanded(
                    child: _buildOverviewCard(
                      title: 'Regular Users',
                      count: regularUsers.length,
                      color: const Color(0xFFE8F5E9),
                      borderColor: Colors.greenAccent,
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Admin Users Section
                        _buildUserSection(
                          title: 'Admin Users',
                          count: adminUsers.length,
                          color: const Color(0xFFFFEBEE),
                          borderColor: Colors.redAccent,
                          users: adminUsers,
                          isAdmin: true,
                        ),
                        const SizedBox(height: 16),

                        // Regular Users Section
                        _buildUserSection(
                          title: 'Regular Users',
                          count: regularUsers.length,
                          color: const Color(0xFFE8F5E9),
                          borderColor: Colors.greenAccent,
                          users: regularUsers,
                          isAdmin: false,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required int count,
    required Color color,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: borderColor, size: 28)],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: borderColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection({
    required String title,
    required int count,
    required Color color,
    required Color borderColor,
    required List<Map<String, dynamic>> users,
    required bool isAdmin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: borderColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Cards
          if (users.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: users
                    .map((user) => _buildUserCard(user, isAdmin))
                    .toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No ${isAdmin ? 'admin' : 'regular'} users',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username with Avatar
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isAdmin
                    ? const Color(0xFFEF5350)
                    : const Color(0xFF4CAF50),
                child: Text(
                  user['username'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFFFFCDD2)
                                : const Color(0xFFC8E6C9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user['role'],
                            style: TextStyle(
                              fontSize: 11,
                              color: isAdmin
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Registration Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Registered: ${user['registered']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isAdmin) {
                  _demoteUser(user['username']);
                } else {
                  _promoteUser(user['username']);
                }
              },
              icon: Icon(
                isAdmin ? Icons.arrow_downward : Icons.arrow_upward,
                size: 16,
              ),
              label: Text(
                isAdmin ? 'Demote to User' : 'Promote to Admin',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdmin
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
