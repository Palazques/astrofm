// Basic Flutter widget test for Astro.FM

import 'package:flutter_test/flutter_test.dart';
import 'package:astrofm/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AstroFmApp());

    // Verify that our app title is displayed.
    expect(find.text('ASTRO.FM'), findsOneWidget);
    expect(find.text('Your Cosmic Sound Profile'), findsOneWidget);
  });
}
