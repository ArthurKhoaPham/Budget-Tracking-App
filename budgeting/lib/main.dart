import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "login_page.dart";
import 'dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PLACEHOLDERS: Replace these with actual project url and anon public key in production
  await Supabase.initialize(
    url: 'https://bufxdyzqftlfwckdxipd.supabase.co',
    anonKey: 'sb_publishable_FkEwhXvbafVcfYKZy4cicw_qoZq3-TD',
  );

  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5A4C)),
        useMaterial3: true,
      ),
      // Placeholder UUID
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginPage()
          : const DashboardPage(),
    );
  }
}
