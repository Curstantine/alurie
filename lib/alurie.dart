library alurie;

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'src/syntaxes.dart';
import 'src/converter.dart';
import 'src/visitor.dart';

class Alurie extends StatelessWidget {
  final String data;
  final AlurieStyle? style;
  final void Function(String)? onTapLink;
  final Widget Function(String, String)? videoBuilder;
  final Widget Function(String, int)? imageBuilder;

  const Alurie({
    super.key,
    required this.data,
    this.style,
    this.onTapLink,
    this.videoBuilder,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Parse markdown string to md.Node
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        SpoilerSyntax(),
        VideoSyntax(),
        SizedImageSyntax(),
      ],
      blockSyntaxes: [
        CenterBlockSyntax(),
      ],
    );
    final mdNodes = document.parseLines(data.split('\n'));

    // 2. Convert md.Node to mdast.Node
    final converter = Converter();
    final mdastNodes = converter.convert(mdNodes);

    // 3. Render mdast.Node to Flutter Widgets
    final visitor = MdastWidgetVisitor(
      style: style ?? const AlurieStyle(),
      onTapLink: onTapLink,
      videoBuilder: videoBuilder,
      imageBuilder: imageBuilder,
    );
    final widgets = visitor.visitNodes(mdastNodes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class AlurieStyle {
  final TextStyle? paragraph;
  final TextStyle? h1;
  final TextStyle? h2;
  final TextStyle? h3;
  final TextStyle? h4;
  final TextStyle? h5;
  final TextStyle? h6;
  final TextStyle? strong;
  final TextStyle? emphasis;
  final TextStyle? code;
  final TextStyle? link;
  final TextStyle? spoiler;

  const AlurieStyle({
    this.paragraph,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.strong,
    this.emphasis,
    this.code,
    this.link,
    this.spoiler,
  });
}
