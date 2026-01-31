import 'package:flutter_test/flutter_test.dart';
import 'package:cvblocks/main.dart';

void main() {
  testWidgets('Welcome message smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our welcome message is displayed.
    expect(find.text('Welcome to CV Blocks'), findsOneWidget);
  });
}
