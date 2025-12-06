import 'package:flutter/material.dart';
import 'package:gas_in/AdminModule/screen/users_api.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart'; // Import service

class PageUsers extends StatefulWidget {
  const PageUsers({super.key});

  @override
  State<PageUsers> createState() => _PageUsersState();
}

class _PageUsersState extends State<PageUsers> {
  final TextEditingController _promoteController = TextEditingController();
  final TextEditingController _demoteController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Load users setelah widget mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  // Method untuk load data dari API
  Future<void> _loadUsers() async {
    final request = context.read<CookieRequest>();
    
    // Check apakah user sudah login
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
      // Pakai UserService dengan CookieRequest
      final fetchedUsers = await UserService.getAllUsers(request);
      setState(() {
        users = fetchedUsers.map((user) => {
          'username': user.username,
          'role': user.role,
          'registered': user.formattedDate,
        }).toList();
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
      // Kirim request dengan CookieRequest
      final result = await UserService.promoteUser(request, username);
      
      // Reload data dari server untuk update UI
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '$username promoted to Admin'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _promoteController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _demoteUser(String username) async {
    final request = context.read<CookieRequest>();
    
    try {
      // Kirim request dengan CookieRequest
      final result = await UserService.demoteUser(request, username);
      
      // Reload data dari server
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '$username demoted to User'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _demoteController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); // Ambil di build(), bukan di initState
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
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
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurpleAccent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User Management',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Promote or demote users to/from admin role',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    onPressed: _loadUsers,
                                    tooltip: 'Refresh',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Promote and Demote Section
                              Row(
                                children: [
                                  // Promote User to Admin
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Promote User to Admin',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: _promoteController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter username',
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  if (_promoteController.text.isNotEmpty) {
                                                    _promoteUser(_promoteController.text);
                                                  }
                                                },
                                                icon: const Icon(Icons.arrow_upward),
                                                label: const Text('Promote'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Demote Admin to User
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Demote Admin to User',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: _demoteController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter username',
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  if (_demoteController.text.isNotEmpty) {
                                                    _demoteUser(_demoteController.text);
                                                  }
                                                },
                                                icon: const Icon(Icons.arrow_downward),
                                                label: const Text('Demote'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange[700],
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // All Users Table
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'All Users',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${users.length} users',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(1.5),
                                        2: FlexColumnWidth(1.5),
                                        3: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        // Header
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                          ),
                                          children: [
                                            _buildTableHeader('Username'),
                                            _buildTableHeader('Role'),
                                            _buildTableHeader('Registered'),
                                            _buildTableHeader('Actions'),
                                          ],
                                        ),
                                        // Data rows
                                        ...users.map((user) {
                                          return TableRow(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              _buildTableCell(user['username']),
                                              _buildTableCell(
                                                user['role'],
                                                isRole: true,
                                                role: user['role'],
                                              ),
                                              _buildTableCell(user['registered']),
                                              _buildTableCell(
                                                '',
                                                isAction: true,
                                                user: user,
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isRole = false,
    String? role,
    bool isAction = false,
    Map<String, dynamic>? user,
  }) {
    if (isRole) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: role == 'Admin' ? Colors.red : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isAction && user != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            if (user['role'] == 'User') {
              _promoteUser(user['username']);
            } else {
              _demoteUser(user['username']);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                user['role'] == 'User' ? Colors.green : Colors.orange[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: Text(user['role'] == 'User' ? 'Promote' : 'Demote'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _promoteController.dispose();
    _demoteController.dispose();
    super.dispose();
  }
}