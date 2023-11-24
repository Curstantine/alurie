import "package:alurie/mdast/abstract.dart";

/// Only includes [Blockquote] | [Code] | [Heading] | [Html] | [List]
typedef FlowContent = Node;

/// Only includes [Break] | [Emphasis] | [Html] | [Image] |  [InlineCode] | [Link] | [Strong] | [Text]
typedef PhrasingContent = Node;

final class Blockquote implements Parent {
  @override
  final type = "blockquote";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<FlowContent> children;

  const Blockquote({required this.children, this.position});
}

final class Break implements Node {
  @override
  final type = "break";

  @override
  final data = null;

  @override
  final Position? position;

  const Break({this.position});
}

/// Spec: https://github.com/syntax-tree/mdast?tab=readme-ov-file#code
final class Code implements Literal {
  @override
  final type = "code";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String value;

  final String? lang;
  final String? meta;

  const Code({this.position, required this.value, this.lang, this.meta});
}

/// https://github.com/syntax-tree/mdast?tab=readme-ov-file#definition
final class Definition implements Node, Association, Resource {
  @override
  final type = "definition";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String identifier;

  @override
  final String? label;

  @override
  final String url;

  @override
  final String? title;

  const Definition({
    this.position,
    required this.identifier,
    this.label,
    required this.url,
    this.title,
  });
}

final class Emphasis implements Parent {
  @override
  final type = "emphasis";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<PhrasingContent> children;

  const Emphasis({required this.children, this.position});
}

final class Heading implements Parent {
  @override
  final type = "heading";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<PhrasingContent> children;

  final int depth;

  const Heading({required this.children, this.position, required this.depth})
      : assert(1 <= depth || 6 >= depth);
}

final class Html implements Literal {
  @override
  final type = "html";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String value;

  const Html({this.position, required this.value});
}

final class Image implements Node, Resource, Alternative {
  @override
  final type = "image";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String url;

  @override
  final String? title;

  @override
  final String? alt;

  const Image({
    this.position,
    required this.url,
    this.title,
    this.alt,
  });
}

final class InlineCode implements Literal {
  @override
  final type = "inlineCode";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String value;

  const InlineCode({this.position, required this.value});
}

/// Spec: https://github.com/syntax-tree/mdast?tab=readme-ov-file#link
final class Link implements Parent, Resource {
  @override
  final type = "link";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<PhrasingContent> children;

  @override
  final String url;

  @override
  final String? title;

  const Link({required this.children, this.position, required this.url, this.title});
}

/// Spec: https://github.com/syntax-tree/mdast?tab=readme-ov-file#list
final class EList implements Parent {
  @override
  final type = "list";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<EListItem> children;

  final bool ordered;
  final double? start;
  final bool spread;

  const EList({
    this.position,
    required this.children,
    this.ordered = false,
    this.start,
    this.spread = false,
  }) : assert(ordered == false && start == null, "ordered and start must be mutually exclusive");
}

final class EListItem implements Parent {
  @override
  final type = "listItem";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<FlowContent> children;

  final bool spread;

  const EListItem({this.position, required this.children, this.spread = false});
}

final class Paragraph implements Parent {
  @override
  final type = "paragraph";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<PhrasingContent> children;

  const Paragraph({this.position, required this.children});
}

/// Spec: https://github.com/syntax-tree/mdast?tab=readme-ov-file#strong
final class Strong implements Parent {
  @override
  final type = "strong";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final List<PhrasingContent> children;

  const Strong({this.position, required this.children});
}

final class Text implements Literal {
  @override
  final type = "text";

  @override
  final data = null;

  @override
  final Position? position;

  @override
  final String value;

  const Text({this.position, required this.value});
}
