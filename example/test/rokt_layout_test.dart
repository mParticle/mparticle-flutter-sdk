import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mparticle_flutter_sdk/mparticle_flutter_sdk.dart';

void main() {
  group('RoktLayout Widget Tests', () {
    testWidgets('RoktLayout displays placeholder name correctly on Android', (WidgetTester tester) async {
      // Mock the platform to be web
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      // Create a RoktLayout widget with a placeholder name
      const roktLayout = RoktLayout(placeholderName: 'testPlaceholder');

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: roktLayout)));

      // Verify that the RoktLayout is created with the correct placeholder name
      expect(find.byType(RoktLayout), findsOneWidget);
      expect(roktLayout.placeholderName, 'testPlaceholder');

      // Reset the platform override
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('RoktLayout displays placeholder name correctly on iOS', (WidgetTester tester) async {
      // Mock the platform to be iOS
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      // Create a RoktLayout widget with a placeholder name
      const roktLayout = RoktLayout(placeholderName: 'testPlaceholder');

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: roktLayout)));

      // Verify that the RoktLayout is created with the correct placeholder name
      expect(find.byType(RoktLayout), findsOneWidget);
      expect(roktLayout.placeholderName, 'testPlaceholder');

      // Reset the platform override
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('RoktLayout displays unsupported platform message on web', (WidgetTester tester) async {
      // Mock the platform to be web
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      // Create a RoktLayout widget
      const roktLayout = RoktLayout(placeholderName: 'testPlaceholder');

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: roktLayout)));

      // Verify that the unsupported platform message is displayed
      expect(find.textContaining('RoktLayout is not supported'), findsOneWidget);

      // Reset the platform override
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('RoktLayout displays unsupported platform message on unsupported platform', (WidgetTester tester) async {
      // Mock the platform to be an unsupported platform
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      // Create a RoktLayout widget
      const roktLayout = RoktLayout(placeholderName: 'testPlaceholder');

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: roktLayout)));

      // Verify that the unsupported platform message is displayed
      expect(find.textContaining('RoktLayout is not supported'), findsOneWidget);

      // Reset the platform override
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
