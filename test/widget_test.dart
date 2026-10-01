import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dbspeak/main.dart';
import 'package:dbspeak/widgets/voice_mic_button.dart';
import 'package:dbspeak/widgets/sql_view_card.dart';

void main() {
  testWidgets('dbSpeak smoke test and UI verification', (WidgetTester tester) async {
    // Provide adequate viewport for desktop/tablet layout
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build dbSpeak app
    await tester.pumpWidget(const DbSpeakApp());
    await tester.pumpAndSettle();

    // Verify app title and elements
    expect(find.text('dbSpeak'), findsOneWidget);
    expect(find.text('E-Commerce Prod'), findsOneWidget);
    expect(find.byType(VoiceMicButton), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify SQL generated card and results
    expect(find.byType(SqlViewCard), findsOneWidget);
    expect(find.text('Generated SQL'), findsOneWidget);
    expect(find.text('Query Results'), findsOneWidget);
  });

  testWidgets('Voice microphone button activates listening state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const DbSpeakApp());
    await tester.pumpAndSettle();

    // Tap mic button
    await tester.tap(find.byType(VoiceMicButton));
    await tester.pump();

    // Verify listening banner appears
    expect(find.textContaining('Listening...'), findsOneWidget);

    // Cancel listening
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Listening...'), findsNothing);
  });
}
