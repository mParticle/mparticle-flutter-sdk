import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mparticle_flutter_sdk_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'launches the app, navigates to Rokt Layouts and verifies layout population',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    // The app has a 5 second delay for initialization.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Find the 'Rokt Layouts' button, scrolling if necessary.
    final roktButton = find.text('Rokt Layouts');
    await tester.scrollUntilVisible(
      roktButton,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(roktButton, findsOneWidget);

    // Tap the 'Rokt Layouts' button to navigate.
    await tester.tap(roktButton);
    await tester.pumpAndSettle();

    // Now we are on the RoktLayoutsScreen.
    // Find one of the RoktLayout widgets.
    final roktLayoutFinder = find.byKey(const ValueKey('layout1'));
    expect(roktLayoutFinder, findsOneWidget);

    // Get the initial size of the widget.
    final initialSize = tester.getSize(roktLayoutFinder);

    // Find and tap the 'Select Placements' button.
    final selectPlacementsButton = find.text('Select Placements');
    expect(selectPlacementsButton, findsOneWidget);
    await tester.tap(selectPlacementsButton);
    // Give time for the native view to update
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Get the final size of the widget.
    final finalSize = tester.getSize(roktLayoutFinder);

    // Verify that the widget has been populated, indicated by a change in height.
    expect(finalSize.height, greaterThan(initialSize.height));
  });
}
