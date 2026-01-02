import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finsight/app.dart';
import 'package:finsight/core/providers/dashboard_provider.dart';
import 'package:finsight/core/providers/theme_provider.dart';

void main() {
  testWidgets('FinSight app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const FinSightApp(),
      ),
    );

    // Verify that login screen is shown
    expect(find.text('FinSight'), findsOneWidget);
    expect(find.text('Solusi POS & Keuangan UMKM'), findsOneWidget);
  });
}
