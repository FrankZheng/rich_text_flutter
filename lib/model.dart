class Word {
  final String rawWord;
  String prefix;
  String word;
  String postfix;

  Word(this.rawWord) {
    //split the rawWord to prefix, pure word, postfix.
    //1. pure word
    //2. word with some symbols
    // with [, . ? ! : ; "'()[]]
    // abbr, U.S. e.g.
    word = rawWord;
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
    RegExp re = new RegExp(r"\s+");
    List<String> words = rawString.split(re);
    words.forEach((w) {
      Word word = new Word(w);
      colletion.add(word);
    });
  }
}

class Article {
  final WordCollection title;
  final WordCollection body;

  List<Word> words;

  Article(this.title, this.body);

  Future<void> splitWord() async {
    await title.splitWords();
    await body.splitWords();
  }

  void clearSelection() {
    title.selectedWordIndex = null;
    body.selectedWordIndex = null;
  }
}
