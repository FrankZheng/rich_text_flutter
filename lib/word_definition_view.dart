import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'package:dio/dio.dart';

class WordDefinitionView extends StatefulWidget {
  final Word word;

  WordDefinitionView(this.word);

  @override
  _WordDefinitionView createState() => _WordDefinitionView();
}

class _WordDefinitionView extends State<WordDefinitionView> {
  WordDefinition definition;
  String error;

  void init() async {
    //use api to get word's translation
    WordDefinition definition;
    String err;
    var wordCache = WordCache.shared;
    var word = widget.word;
    if (wordCache.contains(word)) {
      definition = wordCache.get(word);
    } else {
      try {
        final url = 'https://api.shanbay.com/bdc/search/?word=${word.word}';
        Response response = await Dio().get(url);
        if (response != null && response.data != null) {
          var jsonObj = response.data;
          if (jsonObj != null) {
            if (jsonObj['status_code'] != 0 || jsonObj['data'] == null) {
              debugPrint(
                  'failed to get the definition of word:$word, response:${jsonObj.toString()}');
              err = '未找到单词释义: ${word.word}';
            } else {
              definition = new WordDefinition(word, jsonObj['data']);
              wordCache.put(word, definition);
            }
          }
        }
        //debugPrint(response.data.toString());
      } catch (e) {
        debugPrint(
            'failed to get word explaination by using api, ${e.toString()}');
        err = e.toString();
      }
    }
    this.setState(() {
      this.definition = definition;
      this.error = err;
    });
  }

  void onTapUKSound(WordDefinition definition) {
    playSound(definition.audioUkUrl);
  }

  void onTapUSSound(WordDefinition definition) {
    playSound(definition.audioUsUrl);
  }

  void playSound(String url) async {
    if (url == null) {
      return;
    }
    debugPrint('play sound, $url');
    AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    AudioPlayer.logEnabled = true;
    int result = await audioPlayer.play(url);
    if (result != 1) {
      debugPrint("Failed to play, $result");
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double viewHeight = 120;
    if (definition == null && error == null) {
      //loading
      return Container(
        child: Center(child: CircularProgressIndicator()),
        height: viewHeight,
      );
    } else if (error != null) {
      //error happened
      return Container(
        child: Center(child: Text(error)),
        height: viewHeight,
      );
    } else {
      return Container(
          padding: EdgeInsets.all(8.0),
          height: viewHeight,
          child: ListView(
            children: <Widget>[
              Text('释义'),
              Row(
                children: <Widget>[
                  Text(
                    definition.translatedWord,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('英 [${definition.pronUk}]'),
                  GestureDetector(
                    onTap: () => this.onTapUKSound(definition),
                    child: Icon(
                      Icons.volume_up,
                      size: 20,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('美 [${definition.pronUs}]'),
                  GestureDetector(
                    onTap: () => this.onTapUSSound(definition),
                    child: Icon(
                      Icons.volume_up,
                      size: 20,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              definition.definitionCN != null
                  ? Text(definition.definitionCN)
                  : Text(
                      '未找到',
                      style: TextStyle(color: Colors.grey),
                    ),
            ],
          ));
    }
  }
}
