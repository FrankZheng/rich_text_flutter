import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'package:dio/dio.dart';

class WordDefinitionView extends StatefulWidget {
  final Word word;

  WordDefinitionView(this.word);

  @override
  _WordDefinitionView createState() => _WordDefinitionView();

  static Future<void> show(BuildContext context, Word word) {
    Future<void> ret = showModalBottomSheet<void>(
        context: context,
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0))),
        builder: (BuildContext context) {
          return WordDefinitionView(word);
        });
    return ret;
  }
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
    final double viewHeight = 200;
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
          child: Column(
            children: <Widget>[
              Container(
                height: 24,
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.expand,
                  children: <Widget>[
                    Text(
                      '释义',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    Positioned(
                        right: 0,
                        child: GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          definition.translatedWord,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Text('英 [${definition.pronUk}]'),
                        AnimatedVolumeIcon(
                          size: 24,
                          color: Colors.orange,
                          onTap: () => this.onTapUKSound(definition),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('美 [${definition.pronUs}]'),
                        AnimatedVolumeIcon(
                          size: 24,
                          color: Colors.orange,
                          onTap: () => this.onTapUSSound(definition),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    definition.definitionCN != null
                        ? Text(definition.definitionCN)
                        : Text(
                            '未找到',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              ),
            ],
          ));
    }
  }
}

class AnimatedVolumeIcon extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final Color color;
  AnimatedVolumeIcon({this.size, this.color, this.onTap});

  @override
  _AnimatedVolumeIconState createState() => _AnimatedVolumeIconState();
}

class _AnimatedVolumeIconState extends State<AnimatedVolumeIcon> {
  final List<IconData> icons = [
    Icons.volume_mute,
    Icons.volume_down,
    Icons.volume_up
  ];
  int playCount = 0;
  IconData icon = Icons.volume_up;
  Timer timer;
  void onTap() {
    if (timer == null) {
      widget.onTap();
      //start to animate, for 2s?, and stop
      final int dur = 400;
      int maxCount = 1200 ~/ dur;
      timer = Timer.periodic(Duration(milliseconds: dur), (t) {
        //debugPrint('playCount:$playCount');
        setState(() {
          if (playCount < maxCount) {
            icon = icons[playCount % icons.length];
            playCount++;
          } else {
            playCount = 0;
            timer.cancel();
            timer = null;
            icon = Icons.volume_up;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: widget.size, color: widget.color));
  }
}
