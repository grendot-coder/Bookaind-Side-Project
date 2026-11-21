// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookaind/app/app.dart';

void main() {
  testWidgets('App smoke test verifies introductory screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: JustMoveItApp()));
    await tester.pump();

    expect(find.text('BOOKAIND'), findsWidgets);
    expect(find.text('MASJID ISTIQLAL'), findsOneWidget);
    expect(find.text('Swipe up or tap to explore'), findsOneWidget);
  });
}
