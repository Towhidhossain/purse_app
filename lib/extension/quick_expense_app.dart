import 'package:flutter/material.dart';
import 'quick_expense_screen.dart';

class QuickExpenseApp extends StatelessWidget {
  const QuickExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Purse - Quick Expense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7A5F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const QuickExpenseScreen(),
    );
  }
}
