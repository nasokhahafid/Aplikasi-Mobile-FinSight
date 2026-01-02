import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finsight/app.dart';
import 'package:finsight/core/providers/dashboard_provider.dart';
import 'package:finsight/core/providers/theme_provider.dart';
import 'package:finsight/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FinSightApp(),
    ),
  );
}
