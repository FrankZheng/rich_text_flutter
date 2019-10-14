import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rich_text_flutter/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '小强英语'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Article article;

  void init() async {
    String str = await rootBundle.loadString('assets/article1.txt');
    WordCollection title = new WordCollection("Warlrus joins in");
    WordCollection body = new WordCollection(str);
    Article article = new Article(title, body);
    await article.splitWord();
    setState(() {
      this.article = article;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void onPressed() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Text('hello'),
            padding: EdgeInsets.all(7), //在textField()的所有方向加7单位的边距（空白）
          );
        });
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
          if (word.prefix != null) TextSpan(text: word.prefix),
          TextSpan(text: word.word, style: selectedStyle),
          if (word.postfix != null) TextSpan(text: word.postfix),
          TextSpan(text: ' '),
        ]);
      } else {
        //unselected, make the prefix+word+postfix+space as whole span
        TapGestureRecognizer recognizer = new TapGestureRecognizer();
        recognizer.onTap = () {
          this.onTapWord(word);
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
      text: new TextSpan(children: spans, style: normalStyle),
    );
  }

  Widget title() {
    debugPrint('buildTitle');
    assert(article != null && article.title != null);
    TextStyle normalStyle =
        new TextStyle(color: Colors.black, fontSize: 20, height: 1.2);
    TextStyle selectedStyle =
        new TextStyle(color: Colors.blue, fontSize: 20, height: 1.2);
    return buildWordCollectionWidget(article.title, normalStyle, selectedStyle);
  }

  Widget body() {
    debugPrint('buildBody');
    assert(article != null && article.body != null);
    TextStyle normalStyle =
        new TextStyle(color: Colors.black, fontSize: 20, height: 1.5);
    TextStyle selectedStyle = new TextStyle(
        color: Colors.black,
        backgroundColor: Colors.yellow,
        fontSize: 20,
        height: 1.5);
    return buildWordCollectionWidget(article.body, normalStyle, selectedStyle);
  }

  void onTapWord(Word word) {
    debugPrint('tap word:${word.word}');
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
              child: Column(
                children: <Widget>[
                  title(),
                  SizedBox(
                    height: 10,
                  ),
                  body(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: content,
      ),
    );
  }
}
