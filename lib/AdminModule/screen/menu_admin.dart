import 'package:flutter/material.dart';
import 'package:gas_in/AdminModule/widgets/left_drawer.dart';
import 'package:gas_in/AdminModule/widgets/buttons_card.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final List<ItemAdminpage> items = [
    ItemAdminpage(
      "Users Management",
      Icons.people,
      const Color(0xFF00B894),
      "Promote or demote users to/from admin role. Manage user permissions and access levels.",
    ),
    ItemAdminpage(
      "Events Request Management",
      Icons.event_available,
      const Color(0xFF0984E3),
      "Review and approve event requests from users. Monitor pending, approved, and rejected events.",
    ),
    ItemAdminpage(
      "Logout",
      Icons.logout,
      const Color(0xFFD63031),
      "Sign out from admin panel and return to login page.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 0,
      ),
      drawer: LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C5CE7),
                      const Color(0xFF6C5CE7).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your platform efficiently',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Admin Actions Title
              const Text(
                'Admin Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 16),

              // Action Cards - Vertical Layout
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ItemCard(item),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}