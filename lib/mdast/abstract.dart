interface class Data {}

interface class Point {
  final int line;
  final int column;
  final int offset;

  const Point({required this.line, required this.column, required this.offset});
}

interface class Position {
  final Point start;
  final Point end;

  const Position({required this.start, required this.end});
}

interface class Node {
  final String type;
  final Data? data;
  final Position? position;

  const Node({required this.type, this.data, this.position});
}

interface class Parent extends Node {
  final List<Node> children;

  const Parent({
    required super.type,
    required this.children,
    super.data,
    super.position,
  });
}

interface class Literal extends Node {
  final String value;

  const Literal({
    required super.type,
    super.data,
    super.position,
    required this.value,
  });
}

/// Spec: https://github.com/syntax-tree/mdast?tab=readme-ov-file#association
interface class Association {
  final String identifier;
  final String? label;

  const Association({required this.identifier, required this.label});
}

interface class Resource {
  final String url;
  final String? title;

  const Resource({required this.url, this.title});
}

interface class Alternative {
  final String? alt;

  const Alternative({this.alt});
}
