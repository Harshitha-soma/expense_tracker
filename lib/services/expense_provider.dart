import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  double _monthlyBudget = 500.0; // Default monthly budget limit

  List<Expense> get expenses => [..._expenses];
  bool get isLoading => _isLoading;
  double get monthlyBudget => _monthlyBudget;

  ExpenseProvider() {
    loadData();
  }

  // Load expenses and budget from device storage
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? expensesString = prefs.getString('saved_expenses');
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? 500.0;
      
      if (expensesString != null) {
        final List<dynamic> decodedData = jsonDecode(expensesString);
        _expenses = decodedData.map((item) => Expense.fromMap(item)).toList();
      } else {
        // Initial sample data
        _expenses = [
          Expense(
            id: '1',
            title: 'Grocery Shopping',
            amount: 45.50,
            category: 'Food',
            date: DateTime.now().subtract(const Duration(days: 1)),
            note: 'Weekly vegetables and milk',
          ),
          Expense(
            id: '2',
            title: 'Bus Pass',
            amount: 15.00,
            category: 'Travel',
            date: DateTime.now(),
            note: 'Monthly commute pass',
          ),
        ];
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save to device storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_expenses.map((e) => e.toMap()).toList());
      await prefs.setString('saved_expenses', encodedData);
      await prefs.setDouble('monthly_budget', _monthlyBudget);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Update budget goal
  Future<void> updateBudget(double newBudget) async {
    _monthlyBudget = newBudget;
    notifyListeners();
    await _saveToStorage();
  }

  // Add new expense
  Future<void> addExpense(String title, double amount, String category, DateTime date, String note) async {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    _expenses.insert(0, newExpense);
    notifyListeners();
    await _saveToStorage();
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  // Calculate current month's total spending
  double get currentMonthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Category totals for summary
  Map<String, double> get categoryTotals {
    Map<String, double> totals = {};
    for (var expense in _expenses) {
      totals.update(
        expense.category,
        (existingValue) => existingValue + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }
}