import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'add_activity_screen.dart';
import 'app_drawer.dart';

// Data for category spending
class CategorySpending {
  final int categoryId;
  final String name;
  final double amount;
  final Color color;

  CategorySpending({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.color,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<CategorySpending> categorySpendings = [];
  double totalBalance = 0.0;

  // Category ID to name map
  final Map<int, String> categoryIdToName = {
    1: 'Food',
    2: 'Travel Expenses',
    3: 'Rent & Utilities',
    4: 'Entertainment',
    5: 'Budget',
  };

  // Category name to color map
  final Map<String, Color> categoryColors = {
    'Food': const Color(0xFFFFEB3B), // Yellow
    'Travel Expenses': const Color(0xFFF44336), // Red
    'Rent & Utilities': const Color(0xFF00BCD4), // Cyan
    'Taxes': const Color(0xFFFF9800), // Orange
    'Entertainment': const Color(0xFF673AB7), // Blue/Purple
    'Budget': const Color(0xFFE91E63), // Magenta
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
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

      // Fetch all transactions for current user
      final data = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id);

      // Group transactions by category and total amounts
      Map<int, double> categoryAmounts = {};
      for (var transaction in data) {
        final categoryId = transaction['category_id'] as int;
        final amount = double.tryParse(transaction['amount'].toString()) ?? 0.0;
        categoryAmounts[categoryId] =
            (categoryAmounts[categoryId] ?? 0.0) + amount;
      }

      // Build CategorySpending list for all possible categories
      List<CategorySpending> spendings = [];
      categoryIdToName.forEach((categoryId, categoryName) {
        final amount = categoryAmounts[categoryId] ?? 0.0;
        spendings.add(
          CategorySpending(
            categoryId: categoryId,
            name: categoryName,
            amount: amount,
            color: categoryColors[categoryName] ?? Colors.grey,
          ),
        );
      });

      // Add Taxes category
      spendings.add(
        CategorySpending(
          categoryId: 6,
          name: 'Taxes',
          amount: categoryAmounts[6] ?? 0.0,
          color: categoryColors['Taxes'] ?? Colors.orange,
        ),
      );

      // Calculate total balance
      double total = 0.0;
      for (var spending in spendings) {
        total += spending.amount;
      }

      setState(() {
        categorySpendings = spendings;
        totalBalance = total;
        _isLoading = false;
      });
    } catch (error) {
      _showSnackBar('Error loading dashboard: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatMoney(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  void _navigateToAddActivity() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddActivityScreen(userId: user.id),
        ),
      ).then((_) {
        // Reload data when returning from AddActivityScreen
        _loadDashboardData();
      });
    } else {
      _showSnackBar('Please log in first.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F2),
      drawer: const AppDrawer(),
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
                            const SizedBox(height: 50),
                            _buildPieChart(),
                            const SizedBox(height: 50),
                            _buildCategoryCards(),
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
            'DASHBOARD',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _navigateToAddActivity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9AD9C6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    '+ Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
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

  Widget _buildPieChart() {
    // Filter out categories with 0 amount for pie chart display
    Map<String, double> pieData = {};
    for (var spending in categorySpendings) {
      if (spending.amount > 0) {
        pieData[spending.name] = spending.amount;
      }
    }

    // Create color list for pie chart
    List<Color> colorList = [];
    pieData.forEach((name, amount) {
      colorList.add(categoryColors[name] ?? Colors.grey);
    });

    if (pieData.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'No spending data yet',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9AD9C6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: _navigateToAddActivity,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+ Add Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: PieChart(
            dataMap: pieData,
            animationDuration: const Duration(milliseconds: 800),
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            colorList: colorList,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 30,
            legendOptions: const LegendOptions(showLegends: false),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatMoney(totalBalance),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: categorySpendings.map((spending) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Category color dot
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: spending.color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Category name
                  Expanded(
                    child: Text(
                      spending.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Amount display
                  Text(
                    _formatMoney(spending.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Plus button
                  GestureDetector(
                    onTap: _navigateToAddActivity,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA7E2D1),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
