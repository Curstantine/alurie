import 'package:flutter/material.dart';
import 'package:alurie/alurie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alurie Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
# Anilist Flavored Markdown Demo

This is a demonstration of the **Alurie** package, which parses and renders _Anilist-flavored_ Markdown!

---

## 1. Spoilers

I have a secret for you: ~!This is a hidden spoiler!~.
You can even put **bold** text inside: ~!**Gasp!**!~

## 2. Media Embeds

Here is an example of a Youtube embed using `youtube(id)` syntax:

youtube(dQw4w9WgXcQ)

And a WebM using `webm(url)` syntax:

webm(https://files.kiniro.uk/video/sonic.webm)

## 3. Centered Text

You can center your text like this:

~~~
Look at me, I'm perfectly balanced.
~~~

## 4. Sized Images

Standard markdown images:
![fallback](https://anilist.co/img/icons/icon.svg)

Sized image:
img200(https://anilist.co/img/icons/icon.svg)

## 5. Standard Markdown

Of course, standard Markdown like blockquotes, code, and lists work perfectly!

> Hello World

```dart
void hello() {
  print('Hello Alurie!');
}
```

* List Item 1
* List Item 2
    ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alurie Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Alurie(
            data: markdownData,
            style: AlurieStyle(
              h1: Theme.of(context).textTheme.headlineLarge,
              h2: Theme.of(context).textTheme.headlineMedium,
              paragraph: Theme.of(context).textTheme.bodyLarge,
              spoiler: const TextStyle(
                backgroundColor: Colors.black,
                color: Colors.black,
              ),
            ),
            videoBuilder: (url, type) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Video ($type): $url',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
