import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _addMoneyController = TextEditingController();
  final TextEditingController _setGoalController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  int? goalId;
  double targetAmount = 1000.00;
  double currentAmount = 780.00;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  @override
  void dispose() {
    _addMoneyController.dispose();
    _setGoalController.dispose();
    super.dispose();
  }

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get progressPercent {
    return (progress * 100).round();
  }

  Future<void> _loadGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = await supabase
          .from('goals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        setState(() {
          goalId = data['id'] as int;
          targetAmount =
              double.tryParse(data['target_amount'].toString()) ?? 1000.00;
          currentAmount =
              double.tryParse(data['current_amount'].toString()) ?? 0.00;
        });
      }
    } catch (error) {
      _showSnackBar('Error loading goal: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitGoalUpdate() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showSnackBar('Please log in first.');
      return;
    }

    final addMoneyText = _addMoneyController.text.trim();
    final setGoalText = _setGoalController.text.trim();

    final double addMoney = double.tryParse(addMoneyText) ?? 0;
    final double? newGoal = setGoalText.isNotEmpty
        ? double.tryParse(setGoalText)
        : null;

    if (addMoneyText.isEmpty && setGoalText.isEmpty) {
      _showSnackBar('Enter money saved or set a new goal.');
      return;
    }

    if (addMoney < 0) {
      _showSnackBar('Money saved cannot be negative.');
      return;
    }

    if (newGoal != null && newGoal <= 0) {
      _showSnackBar('Goal must be greater than 0.');
      return;
    }

    final updatedTarget = newGoal ?? targetAmount;
    final updatedCurrent = currentAmount + addMoney;

    if (updatedCurrent > updatedTarget) {
      _showSnackBar('Money saved cannot be greater than the goal.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (goalId == null) {
        final inserted = await supabase
            .from('goals')
            .insert({
              'user_id': user.id,
              'name': 'Main Savings Goal',
              'target_amount': updatedTarget,
              'current_amount': updatedCurrent,
              'last_updated': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        setState(() {
          goalId = inserted['id'] as int;
        });
      } else {
        await supabase
            .from('goals')
            .update({
              'target_amount': updatedTarget,
              'current_amount': updatedCurrent,
              'last_updated': DateTime.now().toIso8601String(),
            })
            .eq('id', goalId!);
      }

      setState(() {
        targetAmount = updatedTarget;
        currentAmount = updatedCurrent;
      });

      _addMoneyController.clear();
      _setGoalController.clear();

      _showSnackBar('Goal updated successfully!');
    } catch (error) {
      _showSnackBar('Error saving goal: $error');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 70),
                            _buildProgressCircle(),
                            const SizedBox(height: 70),
                            _buildGoalCard(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 36, color: Colors.black),
          const SizedBox(width: 15),
          const Text(
            'Goals',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 230,
            height: 230,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 18,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
          Text(
            '$progressPercent%',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.86,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF78B6B7).withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBox('Goal: ${_money(targetAmount)}'),
          const SizedBox(height: 25),
          _infoBox('Money Saved: ${_money(currentAmount)}'),
          const SizedBox(height: 18),
          const Text(
            'Enter Money To save',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _inputBox(controller: _addMoneyController, hintText: 'Example: 50'),
          const SizedBox(height: 18),
          const Text(
            'Set Goal',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _inputBox(controller: _setGoalController, hintText: 'Example: 1000'),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitGoalUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15908E),
                  disabledBackgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 22, color: Colors.black),
    );
  }
}
