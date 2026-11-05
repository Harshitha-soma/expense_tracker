import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryTotals = provider.categoryTotals;
    final totalSpent = provider.currentMonthTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
        actions: [
          // HOME BUTTON ADDED HERE
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Home',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total This Month',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${totalSpent.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: categoryTotals.isEmpty
                  ? const Center(child: Text('No expense data available for summary.'))
                  : ListView(
                      children: categoryTotals.entries.map((entry) {
                        final category = entry.key;
                        final amount = entry.value;
                        final percentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: LinearProgressIndicator(
                              value: totalSpent > 0 ? amount / totalSpent : 0.0,
                              backgroundColor: Colors.grey[200],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}