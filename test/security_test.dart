import 'package:flutter_test/flutter_test.dart';
import 'package:alurie/alurie.dart';
import 'package:flutter/material.dart';

void main() {
  group('Security Fix', () {
    testWidgets('Block Image: Replaces unsafe URL with error text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: '![alt](javascript:alert(1))'),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.text('Invalid image URL'), findsOneWidget);
    });

    testWidgets('Block SizedImage: Replaces unsafe URL with error text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'img400(javascript:alert(1))'),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.text('Invalid image URL'), findsOneWidget);
    });

    testWidgets('Inline Image: Replaces unsafe URL with error text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'Text ![alt](javascript:alert(1)) more text'),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('[Invalid image URL]'), findsOneWidget);
    });

    testWidgets('Inline SizedImage: Replaces unsafe URL with error text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'Text img400(javascript:alert(1)) more text'),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('[Invalid image URL]'), findsOneWidget);
    });

    testWidgets('Allows safe URLs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: '![alt](https://example.com/image.png)'),
        ),
      ));

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Invalid image URL'), findsNothing);
    });
  });
}
