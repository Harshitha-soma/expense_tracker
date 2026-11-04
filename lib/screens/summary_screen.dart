import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totals = Provider.of<ExpenseProvider>(context).categoryTotals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: totals.isEmpty
          ? const Center(child: Text('No data available for summary.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: totals.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}