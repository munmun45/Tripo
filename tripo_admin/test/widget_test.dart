import 'package:flutter_test/flutter_test.dart';
import 'package:tripo_admin/main.dart';

void main() {
  testWidgets('Admin app builds', (tester) async {
    await tester.pumpWidget(const TripoAdminApp(loggedIn: false));
    expect(find.text('Tripo Admin'), findsOneWidget);
  });
}
