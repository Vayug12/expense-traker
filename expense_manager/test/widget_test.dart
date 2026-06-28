import 'package:flutter_test/flutter_test.dart';

import 'package:expense_manager/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseManagerApp());
    await tester.pumpAndSettle();
    expect(find.text('Expense Manager'), findsOneWidget);
  });
}
