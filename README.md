# Alurie

Reference parser for AniList flavored markdown.

## Features

- Uses [mdast](https://github.com/syntax-tree/mdast) as the AST spec.
- Provides utilities to render AL markdown as flutter widgets.
- Parses AniList features such as Spoilers (`~! !~`), Videos (`youtube(url)`), Center alignment (`~~~...~~~`), and Sized Images (`img###(...)`).

## Usage

Simply use the exported `Alurie` widget. You can pass a `data` string containing markdown, customize styling with `AlurieStyle`, and define your own builders to render media elements.

```dart
import 'package:flutter/material.dart';
import 'package:alurie/alurie.dart';

class MyMarkdownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Alurie(
      data: '''
# Hello World!

This is an Anilist-flavored markdown: ~!Spoiler!~

youtube(dQw4w9WgXcQ)
      ''',
      style: AlurieStyle(
        h1: const TextStyle(color: Colors.blue, fontSize: 32, fontWeight: FontWeight.bold),
        spoiler: const TextStyle(backgroundColor: Colors.black, color: Colors.black),
      ),
      videoBuilder: (url, type) {
        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(8.0),
          child: Text('Video Type: \$type, URL: \$url', style: const TextStyle(color: Colors.white)),
        );
      },
      imageBuilder: (url, size) {
        return Image.network(url, width: size.toDouble());
      },
      onTapLink: (url) {
        print('Link tapped: \$url');
      },
    );
  }
}
```
