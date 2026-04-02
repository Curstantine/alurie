import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../mdast/abstract.dart' as mdast;
import '../mdast/nodes.dart' as mdast_nodes;
import '../alurie.dart';

class MdastWidgetVisitor {
  final AlurieStyle style;
  final void Function(String)? onTapLink;
  final Widget Function(String, String)? videoBuilder;
  final Widget Function(String, int)? imageBuilder;

  MdastWidgetVisitor({
    required this.style,
    this.onTapLink,
    this.videoBuilder,
    this.imageBuilder,
  });

  List<Widget> visitNodes(List<mdast.Node> nodes) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      final widget = _visitNode(node);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }

  Widget? _visitNode(mdast.Node node) {
    if (node is mdast_nodes.Paragraph) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RichText(
          text: TextSpan(
            style: style.paragraph ?? const TextStyle(color: Colors.black),
            children: _visitPhrasing(node.children),
          ),
        ),
      );
    } else if (node is mdast_nodes.Heading) {
      TextStyle? headingStyle;
      switch (node.depth) {
        case 1: headingStyle = style.h1 ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold); break;
        case 2: headingStyle = style.h2 ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold); break;
        case 3: headingStyle = style.h3 ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold); break;
        case 4: headingStyle = style.h4 ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold); break;
        case 5: headingStyle = style.h5 ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.bold); break;
        case 6: headingStyle = style.h6 ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.bold); break;
      }
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: RichText(
          text: TextSpan(
            style: headingStyle ?? const TextStyle(color: Colors.black),
            children: _visitPhrasing(node.children),
          ),
        ),
      );
    } else if (node is mdast_nodes.Blockquote) {
      return Container(
        decoration: style.blockquoteDecoration ?? const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey, width: 4.0)),
        ),
        padding: style.blockquotePadding ?? const EdgeInsets.only(left: 8.0),
        margin: style.blockquoteMargin ?? const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: visitNodes(node.children),
        ),
      );
    } else if (node is mdast_nodes.EList) {
      final children = <Widget>[];
      for (var i = 0; i < node.children.length; i++) {
        final item = node.children[i];
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.ordered ? '${i + 1}. ' : '• '),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: visitNodes(item.children),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    } else if (node is mdast_nodes.Code) {
      return Container(
        decoration: style.codeBlockDecoration ?? BoxDecoration(color: Colors.grey[200]),
        padding: style.codeBlockPadding ?? const EdgeInsets.all(8.0),
        margin: style.codeBlockMargin ?? const EdgeInsets.only(bottom: 8.0),
        width: double.infinity,
        child: Text(
          node.value,
          style: style.code ?? const TextStyle(fontFamily: 'monospace', color: Colors.black),
        ),
      );
    } else if (node is mdast_nodes.CenterAlign) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: visitNodes(node.children),
        ),
      );
    } else if (node is mdast_nodes.Spoiler) {
        return Container(
          decoration: style.spoilerDecoration ?? const BoxDecoration(color: Colors.black),
          padding: style.spoilerPadding ?? const EdgeInsets.all(4.0),
          child: RichText(
            text: TextSpan(
              style: style.spoiler ?? const TextStyle(color: Colors.black),
              children: _visitPhrasing(node.children),
            ),
          ),
        );
    } else if (node is mdast_nodes.Video) {
      if (videoBuilder != null) {
        return videoBuilder!(node.url, node.videoType);
      }
      return Container(
        decoration: style.videoFallbackDecoration ?? BoxDecoration(color: Colors.grey[300]),
        padding: style.videoFallbackPadding ?? const EdgeInsets.all(8.0),
        margin: style.videoFallbackMargin ?? const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Video (${node.videoType}): ${node.url}',
          style: style.videoFallbackTextStyle ?? const TextStyle(color: Colors.black),
        ),
      );
    } else if (node is mdast_nodes.SizedImage) {
      if (imageBuilder != null) {
        return imageBuilder!(node.url, node.size);
      }
      return Container(
        width: node.size > 0 ? node.size.toDouble() : null,
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Image.network(node.url,
            errorBuilder: (context, error, stackTrace) => Text('Failed to load image: ${node.url}')),
      );
    } else if (node is mdast_nodes.Image) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Image.network(node.url,
            errorBuilder: (context, error, stackTrace) => Text('Failed to load image: ${node.url}')),
      );
    } else if (node is mdast_nodes.Break) {
      return const SizedBox(height: 16);
    } else if (node is mdast_nodes.Text) {
       return Text(node.value, style: style.paragraph ?? const TextStyle(color: Colors.black));
    }

    return null;
  }

  List<InlineSpan> _visitPhrasing(List<mdast_nodes.PhrasingContent> nodes) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is mdast_nodes.Text) {
        spans.add(TextSpan(text: node.value));
      } else if (node is mdast_nodes.Strong) {
        spans.add(TextSpan(
          style: style.strong ?? const TextStyle(fontWeight: FontWeight.bold),
          children: _visitPhrasing(node.children),
        ));
      } else if (node is mdast_nodes.Emphasis) {
        spans.add(TextSpan(
          style: style.emphasis ?? const TextStyle(fontStyle: FontStyle.italic),
          children: _visitPhrasing(node.children),
        ));
      } else if (node is mdast_nodes.InlineCode) {
        spans.add(TextSpan(
          text: node.value,
          style: style.code ?? const TextStyle(fontFamily: 'monospace', backgroundColor: Color(0xFFEEEEEE)),
        ));
      } else if (node is mdast_nodes.Link) {
        spans.add(TextSpan(
          style: style.link ?? const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () {
            if (onTapLink != null) {
              onTapLink!(node.url);
            }
          },
          children: _visitPhrasing(node.children),
        ));
      } else if (node is mdast_nodes.Spoiler) {
        spans.add(WidgetSpan(
          child: Container(
            decoration: style.spoilerDecoration ?? const BoxDecoration(color: Colors.black),
            padding: style.spoilerPadding,
            child: RichText(
              text: TextSpan(
                style: style.spoiler ?? const TextStyle(color: Colors.black, backgroundColor: Colors.black),
                children: _visitPhrasing(node.children),
              ),
            ),
          ),
        ));
      } else if (node is mdast_nodes.Image) {
        spans.add(WidgetSpan(
          child: Image.network(node.url,
              errorBuilder: (context, error, stackTrace) => Text('Failed to load image: ${node.url}')),
        ));
      } else if (node is mdast_nodes.SizedImage) {
        spans.add(WidgetSpan(
          child: imageBuilder != null
              ? imageBuilder!(node.url, node.size)
              : Container(
                  width: node.size > 0 ? node.size.toDouble() : null,
                  child: Image.network(node.url,
                      errorBuilder: (context, error, stackTrace) => Text('Failed to load image: ${node.url}')),
                ),
        ));
      } else if (node is mdast_nodes.Video) {
        spans.add(WidgetSpan(
          child: videoBuilder != null
              ? videoBuilder!(node.url, node.videoType)
              : Container(
                  decoration: style.videoFallbackDecoration ?? BoxDecoration(color: Colors.grey[300]),
                  padding: style.videoFallbackPadding ?? const EdgeInsets.all(4.0),
                  margin: style.videoFallbackMargin,
                  child: Text(
                    'Video (${node.videoType}): ${node.url}',
                    style: style.videoFallbackTextStyle ?? const TextStyle(color: Colors.black),
                  ),
                ),
        ));
      } else if (node is mdast_nodes.Break) {
         spans.add(const TextSpan(text: '\n'));
      }
    }
    return spans;
  }
}
