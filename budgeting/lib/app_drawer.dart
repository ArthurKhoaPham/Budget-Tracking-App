import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_page.dart';
import 'add_activity_screen.dart';
import 'goals_page.dart';
import 'login_page.dart';
import "budget_allocation_page.dart";

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  SupabaseClient get supabase => Supabase.instance.client;

  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context); // closes drawer

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _goToAddActivity(BuildContext context) {
    final user = supabase.auth.currentUser;

    Navigator.pop(context); // closes drawer

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(userId: user.id),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);

    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFEAF4F2),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA7E2D1), Color(0xFF0D3D3D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Budget App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _goTo(context, const DashboardPage()),
            ),

            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Activity'),
              onTap: () => _goToAddActivity(context),
            ),

            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Budget Allocation"),
              onTap: () => _goTo(context, const BudgetAllocationPage()),
            ),

            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Goals'),
              onTap: () => _goTo(context, const GoalsPage()),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}