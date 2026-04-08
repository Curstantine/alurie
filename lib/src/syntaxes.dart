import 'package:markdown/markdown.dart';

class SpoilerSyntax extends InlineSyntax {
  SpoilerSyntax() : super(r'~!(.*?)!~');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final content = match[1]!;
    final inlineParser = InlineParser(content, parser.document);
    final parsedChildren = inlineParser.parse();
    parser.addNode(Element('spoiler', parsedChildren));
    return true;
  }
}

class VideoSyntax extends InlineSyntax {
  VideoSyntax() : super(r'(youtube|webm)\((.*?)\)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    parser.addNode(Element('video', [Text(match[2]!)])..attributes['type'] = match[1]!);
    return true;
  }
}

class CenterBlockSyntax extends BlockSyntax {
  @override
  final RegExp pattern = RegExp(r'^~~~$');

  @override
  bool canParse(BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  Node? parse(BlockParser parser) {
    final childLines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      if (pattern.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      }
      childLines.add(parser.current.content);
      parser.advance();
    }

    final children = BlockParser(
      childLines.map((line) => Line(line)).toList(),
      parser.document,
    ).parseLines();

    return Element('centerAlign', children);
  }
}

class SizedImageSyntax extends InlineSyntax {
  SizedImageSyntax() : super(r'img(\d+)\((.*?)\)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    parser.addNode(Element.empty('sizedImage')
      ..attributes['size'] = match[1]!
      ..attributes['url'] = match[2]!);
    return true;
  }
}
