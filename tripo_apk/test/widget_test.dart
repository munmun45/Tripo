import 'package:flutter_test/flutter_test.dart';
import 'package:tripo/main.dart';

void main() {
  testWidgets('Tripo app boots to splash', (WidgetTester tester) async {
    await tester.pumpWidget(const TripoApp());
    expect(find.text('Tripo'), findsOneWidget);
    expect(find.text('Travel beautifully'), findsOneWidget);
    // Flush splash delay timer so the test binding stays clean.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();
  });
}
