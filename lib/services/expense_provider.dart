import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => [..._expenses];
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadExpenses();
  }

  // Load expenses from device storage
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? expensesString = prefs.getString('saved_expenses');

      if (expensesString != null) {
        final List<dynamic> decodedData = jsonDecode(expensesString);
        _expenses = decodedData.map((item) => Expense.fromMap(item)).toList();
      } else {
        // Default sample data if nothing is saved yet
        _expenses = [
          Expense(
            id: '1',
            title: 'Grocery Shopping',
            amount: 45.50,
            category: 'Food',
            date: DateTime.now().subtract(const Duration(days: 1)),
            note: 'Bought weekly vegetables and milk',
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
      debugPrint('Error loading expenses: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save current expenses list to device storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_expenses.map((e) => e.toMap()).toList());
      await prefs.setString('saved_expenses', encodedData);
    } catch (e) {
      debugPrint('Error saving expenses: $e');
    }
  }

  // Add new expense and save
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

  // Delete expense and update storage
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  // Calculate totals per category for the Summary Screen
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