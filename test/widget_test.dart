import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FitKarma application bootstrap smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitKarmaApp());

    // Verify that the title and core tagline are rendered.
    expect(find.text('FitKarma'), findsOneWidget);
    expect(
      find.text("India's Intelligent Health Operating System"),
      findsOneWidget,
    );
  });
}
