import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_drawer.dart';

class AddActivityScreen extends StatefulWidget {
  final String userId; 
  
  const AddActivityScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _activityName = '';
  double _expenseAmount = 0.0;
  String _recurrenceType = 'Monthly'; 
  int _categoryId = 1; // Maps based on SQL IDs in Categories table

  // Matches check values in PostgreSQL
  final List<String> recurrenceOptions = ['none', 'daily', 'weekly', 'monthly', 'yearly'];
  
  final Map<String, int> categoryOptions = {
    'Food': 1,
    'Travel Expenses': 2,
    'Rent & Utilities': 3,
    'Entertainment': 4,
    'Budget': 5,
  };

  Future<void> _submitActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final supabase = Supabase.instance.client;

        // Perform the insert operation
        await supabase.from('transactions').insert({
          'user_id': widget.userId,
          'category_id': _categoryId,
          'name': _activityName,
          'amount': _expenseAmount,
          'recurrence': _recurrenceType.toLowerCase(), 
        });

        // Show confirmation on success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity added successfully!')),
          );
          Navigator.pop(context); 
        }
      } on PostgrestException catch (error) {
        // DB Error checker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database Error: ${error.message}')),
          );
        }
      } catch (e) {
        // Network Error Checker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Add Activity', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9AD9C6), Color(0xFF1D5A4C)], 
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Current Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F52BA), Color(0xFFD35400)], 
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT BALANCE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('\$500', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Form Fields
                    const Text('Activity Name:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                      onSaved: (value) => _activityName = value!,
                    ),
                    const SizedBox(height: 20),

                    const Text('Expenses:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '\$  ',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter an amount';
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) return 'Enter a valid positive number';
                        return null;
                      },
                      onSaved: (value) => _expenseAmount = double.parse(value!),
                    ),
                    const SizedBox(height: 20),

                    const Text('Recurrence Type:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _recurrenceType.toLowerCase(),
                      items: recurrenceOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value[0].toUpperCase() + value.substring(1)),
                        );
                      }).toList(),
                      onChanged: (newValue) => setState(() => _recurrenceType = newValue!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Activity Type:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      items: categoryOptions.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (newValue) => setState(() => _categoryId = newValue!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SUBMIT
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _submitActivity,
                          child: const Text('SUBMIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}