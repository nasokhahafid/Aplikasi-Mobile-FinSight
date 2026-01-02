import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finsight/core/theme/app_theme.dart';
import 'package:finsight/core/providers/theme_provider.dart';
import 'package:finsight/features/auth/screens/login_screen.dart';

class FinSightApp extends StatelessWidget {
  const FinSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'FinSight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
    );
  }
}
