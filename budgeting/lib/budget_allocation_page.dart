import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "app_drawer.dart";

class BudgetAllocationPage extends StatefulWidget {
  const BudgetAllocationPage({super.key});

  @override
  State<BudgetAllocationPage> createState() => _BudgetAllocationPageState();
}

class _BudgetAllocationPageState extends State<BudgetAllocationPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _limitController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveBudgetLimit() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage("Please log in first.");
      return;
    }

    final limit = double.tryParse(_limitController.text.trim());

    if (limit == null || limit <= 0) {
      _showMessage("Enter a valid monthly limit.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _saveBudgetToNewTable(user.id, limit);

      _limitController.clear();
      _showMessage("Budget limit saved!");
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205') {
        try {
          await _saveBudgetToLegacyTable(user.id, limit);
          _limitController.clear();
          _showMessage("Budget limit saved!");
        } catch (legacyError) {
          _showMessage("Error saving budget: $legacyError");
        }
      } else {
        _showMessage("Error saving budget: $error");
      }
    } catch (error) {
      _showMessage("Error saving budget: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveBudgetToNewTable(String userId, double limit) async {
    await supabase.from("user_budget").upsert({
      "user_id": userId,
      "monthly_limit": limit,
    }, onConflict: "user_id");
  }

  Future<void> _saveBudgetToLegacyTable(String userId, double limit) async {
    await supabase.from("budget_allocation").upsert({
      "user_id": userId,
      "category_id": 5,
      "monthly_limit": limit,
    }, onConflict: "user_id,category_id");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFEAF4F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFA7E2D1), Color(0xFF0D3D3D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF78B6B7).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Set Monthly Budget",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),

                        const SizedBox(height: 22),

                        const Text(
                          "Monthly Limit",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _limitController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            hintText: "Example: 300",
                            prefixText: "\$ ",
                          ),
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveBudgetLimit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF15908E),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text(
                                      "SUBMIT",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade300,
      hintText: hintText,
      prefixText: prefixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, size: 36, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 15),
          const Text(
            "Budget Allocation",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
