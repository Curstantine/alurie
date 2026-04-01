import 'package:markdown/markdown.dart' as md;
import '../mdast/abstract.dart' as mdast;
import '../mdast/nodes.dart' as mdast_nodes;

class Converter {
  List<mdast.Node> convert(List<md.Node> nodes) {
    return nodes.map((node) => _convertNode(node)).whereType<mdast.Node>().toList();
  }

  mdast.Node? _convertNode(md.Node node) {
    if (node is md.Text) {
      return mdast_nodes.Text(value: node.text);
    } else if (node is md.Element) {
      final children = convert(node.children ?? []);

      switch (node.tag) {
        case 'p':
          return mdast_nodes.Paragraph(children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h1':
          return mdast_nodes.Heading(depth: 1, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h2':
          return mdast_nodes.Heading(depth: 2, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h3':
          return mdast_nodes.Heading(depth: 3, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h4':
          return mdast_nodes.Heading(depth: 4, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h5':
          return mdast_nodes.Heading(depth: 5, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'h6':
          return mdast_nodes.Heading(depth: 6, children: children.cast<mdast_nodes.PhrasingContent>());
        case 'strong':
          return mdast_nodes.Strong(children: children.cast<mdast_nodes.PhrasingContent>());
        case 'em':
          return mdast_nodes.Emphasis(children: children.cast<mdast_nodes.PhrasingContent>());
        case 'ul':
        case 'ol':
          return mdast_nodes.EList(
            ordered: node.tag == 'ol',
            children: children.cast<mdast_nodes.EListItem>(),
          );
        case 'li':
          return mdast_nodes.EListItem(children: children.cast<mdast_nodes.FlowContent>());
        case 'blockquote':
          return mdast_nodes.Blockquote(children: children.cast<mdast_nodes.FlowContent>());
        case 'code':
          return mdast_nodes.InlineCode(value: node.textContent);
        case 'pre':
          return mdast_nodes.Code(value: node.textContent);
        case 'a':
          return mdast_nodes.Link(
            url: node.attributes['href'] ?? '',
            title: node.attributes['title'],
            children: children.cast<mdast_nodes.PhrasingContent>(),
          );
        case 'img':
          return mdast_nodes.Image(
            url: node.attributes['src'] ?? '',
            alt: node.attributes['alt'],
            title: node.attributes['title'],
          );
        case 'br':
          return mdast_nodes.Break();
        case 'hr':
          // Can't represent hr with the given mdast spec, using break as fallback
          return mdast_nodes.Break();
        case 'spoiler':
          return mdast_nodes.Spoiler(children: children.cast<mdast_nodes.PhrasingContent>());
        case 'video':
          return mdast_nodes.Video(
            url: node.textContent,
            videoType: node.attributes['type'] ?? 'youtube',
          );
        case 'centerAlign':
          return mdast_nodes.CenterAlign(children: children.cast<mdast_nodes.FlowContent>());
        case 'sizedImage':
          return mdast_nodes.SizedImage(
            url: node.attributes['url'] ?? '',
            size: int.tryParse(node.attributes['size'] ?? '0') ?? 0,
          );
        default:
          // Unrecognized tag, wrap children in a paragraph or return text
          if (children.isNotEmpty) {
            return mdast_nodes.Paragraph(children: children.cast<mdast_nodes.PhrasingContent>());
          }
          return mdast_nodes.Text(value: node.textContent);
      }
    }
    return null;
  }
}
