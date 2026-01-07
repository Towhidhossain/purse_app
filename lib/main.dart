import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purse/constants/app_dark_theme.dart';
import 'package:purse/constants/app_theme.dart';
import './models/database_provider.dart';
import './models/theme_provider.dart';
import './providers/auth_provider.dart';
import './widgets/common/auth_gate.dart';
// screens
import './screens/category_screen.dart';
import './screens/expense_screen.dart';
import './screens/income_screen.dart';
import './screens/transactions_screen.dart';
import './screens/profile_screen.dart';
import './screens/web_landing.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   

    return Consumer<ThemeProvider>(builder: (_, theme, __) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: theme.themeMode,
        theme: appThemeData,
        darkTheme: darkThemeData,
        home: kIsWeb ? const WebLandingScreen() : const AuthGate(),
        routes: {
          '/app': (_) => const AuthGate(),
          CategoryScreen.name: (_) => const CategoryScreen(),
          ExpenseScreen.name: (_) => const ExpenseScreen(),
          IncomeScreen.name: (_) => const IncomeScreen(),
          TransactionsScreen.name: (_) => const TransactionsScreen(),
          ProfileScreen.name: (_) => const ProfileScreen(),
        },
      );
    });
  }
}
