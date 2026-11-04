import 'package:flutter_test/flutter_test.dart';
import 'package:vcomm_mobile/main.dart';

void main() {
  testWidgets('V-COMM app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VCommApp());
    expect(find.byType(VCommApp), findsOneWidget);
  });
}
