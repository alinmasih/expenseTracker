import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:spend_track/main.dart';
import 'package:spend_track/providers/expense_provider.dart';
import 'package:spend_track/providers/theme_provider.dart';

void main() {
  testWidgets('SpendTrack App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ],
        child: const SpendTrackApp(),
      ),
    );

    // Verify app renders
    expect(find.byType(SpendTrackApp), findsOneWidget);
  });
}
