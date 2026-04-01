import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:alurie/src/syntaxes.dart';
import 'package:alurie/src/converter.dart';
import 'package:alurie/mdast/nodes.dart' as mdast_nodes;
import 'package:alurie/alurie.dart';
import 'package:flutter/material.dart';

void main() {
  group('Parser & Converter', () {
    test('Parses and converts standard text', () {
      final document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);
      final mdNodes = document.parseLines(['Hello World']);
      final converter = Converter();
      final mdastNodes = converter.convert(mdNodes);

      expect(mdastNodes.length, 1);
      final p = mdastNodes[0] as mdast_nodes.Paragraph;
      expect((p.children[0] as mdast_nodes.Text).value, 'Hello World');
    });

    test('Parses and converts spoiler syntax', () {
      final document = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: [SpoilerSyntax()],
      );
      final mdNodes = document.parseLines(['This is a ~!secret!~']);
      final converter = Converter();
      final mdastNodes = converter.convert(mdNodes);

      final p = mdastNodes[0] as mdast_nodes.Paragraph;
      expect(p.children.length, 2);
      expect((p.children[0] as mdast_nodes.Text).value, 'This is a ');
      expect((p.children[1] as mdast_nodes.Spoiler).children.length, 1);
      expect(((p.children[1] as mdast_nodes.Spoiler).children[0] as mdast_nodes.Text).value, 'secret');
    });

    test('Parses and converts video syntax', () {
      final document = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: [VideoSyntax()],
      );
      final mdNodes = document.parseLines(['Look: youtube(dQw4w9WgXcQ)']);
      final converter = Converter();
      final mdastNodes = converter.convert(mdNodes);

      final p = mdastNodes[0] as mdast_nodes.Paragraph;
      expect(p.children.length, 2);
      expect((p.children[0] as mdast_nodes.Text).value, 'Look: ');
      expect((p.children[1] as mdast_nodes.Video).url, 'dQw4w9WgXcQ');
      expect((p.children[1] as mdast_nodes.Video).videoType, 'youtube');
    });

    test('Parses and converts sized image syntax', () {
      final document = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: [SizedImageSyntax()],
      );
      final mdNodes = document.parseLines(['Check img400(https://example.com/img.png) out']);
      final converter = Converter();
      final mdastNodes = converter.convert(mdNodes);

      final p = mdastNodes[0] as mdast_nodes.Paragraph;
      expect(p.children.length, 3);
      expect((p.children[0] as mdast_nodes.Text).value, 'Check ');
      expect((p.children[1] as mdast_nodes.SizedImage).url, 'https://example.com/img.png');
      expect((p.children[1] as mdast_nodes.SizedImage).size, 400);
      expect((p.children[2] as mdast_nodes.Text).value, ' out');
    });

    test('Parses and converts center align block syntax', () {
      final document = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        blockSyntaxes: [CenterBlockSyntax()],
      );
      final mdNodes = document.parseLines(['~~~', 'Centered', '~~~']);
      final converter = Converter();
      final mdastNodes = converter.convert(mdNodes);

      expect(mdastNodes.length, 1);
      final c = mdastNodes[0] as mdast_nodes.CenterAlign;
      expect(((c.children[0] as mdast_nodes.Paragraph).children[0] as mdast_nodes.Text).value, 'Centered');
    });
  });

  group('Alurie Widget', () {
    testWidgets('Renders standard markdown', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: '# Heading\n**Bold** and *Italic*'),
        ),
      ));

      expect(find.byType(RichText), findsWidgets);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));

      bool foundHeading = false;
      bool foundBold = false;
      bool foundItalic = false;

      for (final r in richTexts) {
        final textSpan = r.text as TextSpan;
        if (textSpan.toPlainText() == 'Heading') foundHeading = true;
        if (textSpan.toPlainText() == 'Bold and Italic') {
          foundBold = true;
          foundItalic = true;
        }
      }

      expect(foundHeading, isTrue);
      expect(foundBold, isTrue);
      expect(foundItalic, isTrue);
    });

    testWidgets('Renders spoiler tags', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'Here is a ~!spoiler!~'),
        ),
      ));

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));

      bool foundSpoiler = false;

      for (final r in richTexts) {
        final textSpan = r.text as TextSpan;
        if (textSpan.toPlainText().contains('spoiler')) {
          foundSpoiler = true;
        }
      }

      expect(foundSpoiler, isTrue);
    });

    testWidgets('Renders video tags', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'Check this out: youtube(12345) and webm(link.webm)'),
        ),
      ));

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));

      bool foundVideo = false;

      for (final r in richTexts) {
        final textSpan = r.text as TextSpan;
        if (textSpan.toPlainText().contains('Check this out:')) {
            if (textSpan.toPlainText().contains('\uFFFC')) {
                foundVideo = true;
            }
        }
      }

      expect(foundVideo, isTrue);
      expect(find.text('Video (youtube): 12345'), findsOneWidget);
      expect(find.text('Video (webm): link.webm'), findsOneWidget);
    });

    testWidgets('Renders image tags with size', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: 'img400(https://example.com/image.png)'),
        ),
      ));

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final containerFinder = find.ancestor(of: imageFinder, matching: find.byType(Container));
      expect(containerFinder, findsWidgets); // Image size constraint container
    });

    testWidgets('Renders center block tags', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Alurie(data: '~~~\nCenteredText\n~~~'),
        ),
      ));

      expect(find.byType(Center), findsOneWidget);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      bool foundCentered = false;
      for (final r in richTexts) {
        final textSpan = r.text as TextSpan;
        if (textSpan.toPlainText() == 'CenteredText') foundCentered = true;
      }
      expect(foundCentered, isTrue);
    });
  });
}
