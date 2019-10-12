import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rich_text_flutter/model.dart';
import 'dart:convert';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<String> words = [];
  int selectedWordIndex;
  TextEditingController textEditingController = new TextEditingController();
  final Map<String, WordDefinition> wordCache = {};

  void onTapWord(int index) async {
    String word = words[index];
    debugPrint('tap $word');
    //only translate english word, and abbr, remove tailed symbols

    //use api to get word's translation
    WordDefinition definition;
    if (wordCache.containsKey(word)) {
      definition = wordCache[word];
    } else {
      try {
        final url = 'https://api.shanbay.com/bdc/search/?word=$word';
        Response response = await Dio().get(url);
        if (response != null && response.data != null) {
          var jsonObj = response.data;
          if (jsonObj != null) {
            if (jsonObj['status_code'] != 0 || jsonObj['data'] == null) {
              print(
                  'failed to get the definition of word:$word, response:${jsonObj.toString()}');
              return;
            }
            definition = new WordDefinition(word, jsonObj['data']);
            wordCache[word] = definition;
          }
        }
        //debugPrint(response.data.toString());
      } catch (e) {
        print('failed to get word explaination by using api, ${e.toString()}');
      }
    }

    setState(() {
      this.selectedWordIndex = index;
    });
    //figure out a UI to show word's translation
  }

  void showDefinition(WordDefinition definition) {
    debugPrint('Defination');
    debugPrint('UK [${definition.pronUk}] US [${definition.pronUs}]');
    debugPrint('${definition.definitionCN}');
  }

  Widget richText() {
    if (words.isEmpty) {
      return Text("");
    }
    List<InlineSpan> spans = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      TapGestureRecognizer recognizer = new TapGestureRecognizer();
      recognizer.onTap = () {
        this.onTapWord(i);
      };
      TextStyle textStyle;
      if (selectedWordIndex == i) {
        //debugPrint('($word, $selectedWordIndex) selected');
        textStyle = TextStyle(color: Colors.blue);
      }
      spans.add(new TextSpan(
          text: '$word ', recognizer: recognizer, style: textStyle));
    }
    words.forEach((word) {});
    return RichText(
      text: new TextSpan(
          children: spans, style: TextStyle(color: Colors.black, fontSize: 16)),
    );
  }

  void translate() {
    //try to split the input text into words
    String str = textEditingController.text;
    if (str.isEmpty) {
      return;
    }
    List<String> words = str.split(new RegExp(r"\s+"));
    setState(() {
      this.words = words;
    });
  }

  List<Widget> definitionPanel() {
    if (selectedWordIndex != null) {
      String word = words[selectedWordIndex];
      if (wordCache.containsKey(word)) {
        WordDefinition definition = wordCache[word];
        var container = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('释义'),
            Row(
              children: <Widget>[
                Text(
                  definition.word,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('英 [${definition.pronUk}]'),
                Text('美 [${definition.pronUs}]'),
              ],
            ),
            definition.definitionCN != null
                ? Text(definition.definitionCN)
                : Text(
                    '未找到',
                    style: TextStyle(color: Colors.grey),
                  ),
          ],
        );
        return [Spacer(), SizedBox(height: 10), container];
      }
    }

    return [
      SizedBox(
        height: 1,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: TextField(
                  minLines: 5,
                  maxLines: 5,
                  controller: textEditingController,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                child: Text('translate'),
                onPressed: translate,
              ),
              SizedBox(
                height: 10,
              ),
              richText(),
              ...definitionPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
