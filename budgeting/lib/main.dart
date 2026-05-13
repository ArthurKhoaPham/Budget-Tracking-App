import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_activity_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PLACEHOLDERS: Replace these with actual project url and anon public key in production
  await Supabase.initialize(
    url: 'SUPABASE_PROJECT_URL',
    anonKey: 'SUPABASE_ANON_PUBLIC_KEY',
  );

  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5A4C)),
        useMaterial3: true,
      ),
      // Placeholder UUID
      home: const AddActivityScreen(userId: 'YOUR_USER_UUID_HERE'), 
    );
  }
}
