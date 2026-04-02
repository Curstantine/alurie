library alurie;

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'src/syntaxes.dart';
import 'src/converter.dart';
import 'src/visitor.dart';
import 'mdast/abstract.dart' as mdast;

class Alurie extends StatefulWidget {
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
  State<Alurie> createState() => _AlurieState();
}

class _AlurieState extends State<Alurie> {
  late List<mdast.Node> _mdastNodes;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  @override
  void didUpdateWidget(covariant Alurie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _parseData();
    }
  }

  void _parseData() {
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
    final mdNodes = document.parseLines(widget.data.split('\n'));

    // 2. Convert md.Node to mdast.Node
    final converter = Converter();
    _mdastNodes = converter.convert(mdNodes);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Render mdast.Node to Flutter Widgets
    final visitor = MdastWidgetVisitor(
      style: widget.style ?? const AlurieStyle(),
      onTapLink: widget.onTapLink,
      videoBuilder: widget.videoBuilder,
      imageBuilder: widget.imageBuilder,
    );
    final widgets = visitor.visitNodes(_mdastNodes);

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

  final BoxDecoration? blockquoteDecoration;
  final EdgeInsetsGeometry? blockquotePadding;
  final EdgeInsetsGeometry? blockquoteMargin;

  final BoxDecoration? codeBlockDecoration;
  final EdgeInsetsGeometry? codeBlockPadding;
  final EdgeInsetsGeometry? codeBlockMargin;

  final BoxDecoration? spoilerDecoration;
  final EdgeInsetsGeometry? spoilerPadding;

  final BoxDecoration? videoFallbackDecoration;
  final EdgeInsetsGeometry? videoFallbackPadding;
  final EdgeInsetsGeometry? videoFallbackMargin;
  final TextStyle? videoFallbackTextStyle;

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
    this.blockquoteDecoration,
    this.blockquotePadding,
    this.blockquoteMargin,
    this.codeBlockDecoration,
    this.codeBlockPadding,
    this.codeBlockMargin,
    this.spoilerDecoration,
    this.spoilerPadding,
    this.videoFallbackDecoration,
    this.videoFallbackPadding,
    this.videoFallbackMargin,
    this.videoFallbackTextStyle,
  });
}
