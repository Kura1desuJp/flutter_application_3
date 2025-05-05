import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_3/main.dart';

void main() {
  testWidgets('Auth screen is displayed after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const WeightLossCalendarApp());

    // Чекаємо завершення splash (наприклад, 3 секунди + трохи запасу)
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Перевіряємо, що відображається текст на AuthScreen
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.contains('Auth Screen'),
      ),
      findsOneWidget,
    );
  });
}
