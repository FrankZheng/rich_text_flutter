import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rich_text_flutter/word_definition_view.dart';
import 'model.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage(this.article);

  final Article article;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Article article;
  String fontFamily = 'Georgia';

  //font size
  double titleFontMaxSize = 32;
  double titleFontMinSize = 16;
  double titleFontSize = 22;

  double bodyFontMaxSize = 32;
  double bodyFontMinSize = 12;
  double bodyFontSize = 20;

  void init() async {
    await widget.article.splitWord();
    setState(() {
      this.article = widget.article;
    });
  }

  @override
  void initState() {
    init();
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Widget buildWordCollectionWidget(WordCollection wordCollection,
      TextStyle normalStyle, TextStyle selectedStyle) {
    assert(wordCollection.colletion != null &&
        wordCollection.colletion.isNotEmpty);
    List<Word> words = wordCollection.colletion;
    List<TextSpan> spans = [];
    for (int i = 0; i < words.length; i++) {
      final Word word = words[i];
      TextSpan span;
      if (wordCollection.selectedWordIndex == i) {
        //selected
        //make the word a separate span
        span = new TextSpan(children: <TextSpan>[
          if (word.hasPrefix) TextSpan(text: word.prefix),
          TextSpan(text: word.word, style: selectedStyle),
          if (word.hasPostfix != null) TextSpan(text: word.postfix),
          TextSpan(text: ' '),
        ]);
      } else {
        //unselected, make the prefix+word+postfix+space as whole span
        TapGestureRecognizer recognizer = new TapGestureRecognizer();
        recognizer.onTap = () {
          this.onTapWord(word, wordCollection);
          article.clearSelection();
          wordCollection.selectedWordIndex = i;
          //refresh UI to mark the selected word
          setState(() {
            this.article = article;
          });
        };
        span = new TextSpan(text: '${word.rawWord} ', recognizer: recognizer);
      }
      spans.add(span);
    }
    return new RichText(
      textAlign: TextAlign.justify,
      text: new TextSpan(children: spans, style: normalStyle),
    );
  }

  Widget title() {
    //debugPrint('buildTitle');
    assert(article != null && article.title != null);
    TextStyle normalStyle = new TextStyle(
        color: Colors.black,
        fontSize: titleFontSize,
        height: 1.2,
        fontFamily: fontFamily);
    TextStyle selectedStyle =
        new TextStyle(color: Colors.white, backgroundColor: Colors.yellow);
    return buildWordCollectionWidget(article.title, normalStyle, selectedStyle);
  }

  List<Widget> body() {
    //debugPrint('buildBody');
    assert(article != null && article.body != null);
    TextStyle normalStyle = new TextStyle(
        color: Colors.black,
        fontSize: bodyFontSize,
        height: 1.5,
        fontFamily: fontFamily);
    TextStyle selectedStyle =
        new TextStyle(backgroundColor: Colors.yellow, color: Colors.white);

    List<Widget> widgets = [];
    List<Paragraph> paragraphs = article.body;
    for (int i = 0; i < paragraphs.length; i++) {
      Paragraph p = paragraphs[i];
      widgets.add(buildWordCollectionWidget(p, normalStyle, selectedStyle));
      if (i != paragraphs.length - 1) {
        widgets.add(new SizedBox(
          height: 10,
        ));
      }
    }
    return widgets;
  }

  void onTapWord(Word aWord, WordCollection wordCollection) async {
    debugPrint('tap word:${aWord.toString()}');
    await WordDefinitionView.show(context, aWord);
    debugPrint('closed');
    setState(() {
      article.clearSelection();
    });
  }

  void onAdjustFont() {
    String systemFont = DefaultTextStyle.of(context).style.fontFamily;
    List<String> fontFamilies = [
      'Arial',
      'Arial Black',
      'Arial Narrow',
      'Bookman',
      'Bookman Old Style',
      'Century Gothic',
      'Comic Sans MS',
      'Console',
      'Courier',
      'Courier New',
      'Georgia',
      'Helvetica',
      'Impact',
      'Lucida Console',
      'Lucida Sans Unicode',
      'Palantino Linotype',
      'Tahoma',
      'Times New Roman',
      'Trebuchet MS',
      'Verdana'
    ];
    fontFamilies.remove(systemFont);
    fontFamilies.insert(0, '$systemFont(system)');

    showModalBottomSheet(
        context: context,
        builder: (buildContext) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              children: fontFamilies
                  .map((ff) => GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => fontFamily = ff);
                        },
                        child: Padding(
                          child: Text(
                            ff,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: fontFamily == ff
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                          padding: EdgeInsets.all(8.0),
                        ),
                      ))
                  .toList(),
            ),
          );
        });
  }

  void onAdjustFontSize(bool increase) {
    setState(() {
      if (increase) {
        titleFontSize = min(titleFontSize + 2, titleFontMaxSize);
        bodyFontSize = min(bodyFontSize + 2, bodyFontMaxSize);
      } else {
        titleFontSize = max(titleFontSize - 2, titleFontMinSize);
        bodyFontSize = max(bodyFontSize - 2, bodyFontMinSize);
      }
      debugPrint('titleFontSize:$titleFontSize, bodyFontSize:$bodyFontSize');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    Widget content;
    if (article == null) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    title(),
                    SizedBox(
                      height: 20,
                    ),
                    ...body(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    Color iconColor = Colors.black45;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.navigate_before,
            color: iconColor,
            size: 36,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.font_download, color: iconColor),
            onPressed: onAdjustFont,
          ),
          PopupMenuButton<bool>(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.format_size, color: iconColor),
            ),
            onSelected: (value) {
              onAdjustFontSize(value);
            },
            itemBuilder: (context) {
              return <PopupMenuItem<bool>>[
                PopupMenuItem<bool>(
                  child: Text('increase'),
                  value: true,
                ),
                PopupMenuItem<bool>(
                  child: Text('decrease'),
                  value: false,
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: content,
      ),
    );
  }
}
