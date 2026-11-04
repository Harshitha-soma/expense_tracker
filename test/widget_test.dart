import 'package:flutter/material.dart'; // <-- Make sure this line is here!
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense tracker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}