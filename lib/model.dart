import 'package:flutter/services.dart';

class Word {
  final String rawWord;
  String prefix;
  String word;
  String postfix;

  bool get hasPrefix => prefix != null && prefix.isNotEmpty;

  bool get hasPostfix => postfix != null && postfix.isNotEmpty;

  String toString() {
    return 'raw:$rawWord,prefix:$prefix, word:$word, postfix:$postfix';
  }

  Word(this.rawWord) {
    //split the rawWord to prefix, pure word, postfix.
    //1. pure word
    //2. word with some symbols
    // with [, . ? ! : ; "'()[]]
    // abbr, U.S. e.g.
    List<String> patterns = [
      r'([A-Za-z]\.)+',
      r'\d+\w+',
      r"\w+[’']\w*",
      r'\w+(-\w+)*'
    ];
    String pattern = patterns.join('|');
    RegExp re = new RegExp(pattern);
    var match = re.firstMatch(rawWord);
    if (match != null) {
      prefix = rawWord.substring(0, match.start);
      word = rawWord.substring(match.start, match.end);
      postfix = rawWord.substring(match.end);
    } else {
      word = rawWord;
    }
  }
}

class WordDefinition {
  final Word word; //orginal word to translate
  String
      translatedWord; //translated word, for example, search looked, translate look
  final Map<String, dynamic> rawData;

  String pronUk; //uk pronunciation
  String pronUs; //us pronunciation
  String audioUkUrl; //uk audio url
  String audioUsUrl; //us audio url
  String definitionCN; //cn defintion

  WordDefinition(this.word, this.rawData) {
    var pronunciations = rawData['pronunciations'];
    if (pronunciations != null) {
      pronUk = pronunciations['uk'];
      pronUs = pronunciations['us'];
    }
    audioUkUrl = rawData['uk_audio'];
    audioUsUrl = rawData['us_audio'];

    var definition = rawData['cn_definition'];
    if (definition != null) {
      definitionCN = definition['defn'];
      if (definitionCN != null) {
        definitionCN = definitionCN.replaceAll(new RegExp("\n"), '');
      }
    }
    translatedWord = rawData['content'] ?? word;
  }
}

class WordCollection {
  final String rawString;
  List<Word> colletion = [];
  WordCollection(this.rawString);
  int selectedWordIndex;

  Future<void> splitWords() async {
    //here may put the code into isolate to avoid block main thread
    //use string.split to split raw string to several words
    RegExp re = new RegExp(r"[ \f\r\t\v]");
    List<String> words = rawString.split(re);
    words.forEach((w) {
      Word word = new Word(w);
      colletion.add(word);
    });
  }
}

class Paragraph extends WordCollection {
  Paragraph(String rawString) : super(rawString);
}

class Article {
  String titleString; //title
  String bodyString; //body
  String coverUrl; //cover
  String bodyUrl;

  WordCollection title;
  List<Paragraph> body = [];

  Article(this.titleString, this.bodyString);

  Article.fromMap(Map<String, dynamic> map) {
    titleString = map['title'];
    bodyUrl = map['body_url'];
    coverUrl = map['cover'];
  }

  Future<void> splitWord() async {
    //title
    title = new WordCollection(titleString);
    await title.splitWords();

    //body
    bodyString = await rootBundle.loadString(bodyUrl);
    RegExp re = new RegExp(r"\n+");
    List<String> paragraphStrs = bodyString.split(re);
    paragraphStrs.forEach((p) async {
      Paragraph paragraph = new Paragraph(p);
      await paragraph.splitWords();
      body.add(paragraph);
    });
  }

  void clearSelection() {
    title.selectedWordIndex = null;
    body.forEach((p) => p.selectedWordIndex = null);
  }
}

class WordCache {
  static final WordCache shared = new WordCache();
  Map<String, WordDefinition> _map = {};

  WordDefinition get(Word word) {
    return _map[word.word];
  }

  void put(Word word, WordDefinition definition) {
    _map[word.word] = definition;
  }

  bool contains(Word word) => _map.containsKey(word.word);
}
