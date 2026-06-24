import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_mobile/app.dart';

void main() {
  testWidgets('AutoCare app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCareApp());

    expect(find.text('AutoCare'), findsOneWidget);
  });
}