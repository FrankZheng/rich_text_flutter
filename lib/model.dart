class WordDefinition {
  final String word; //orginal word to translate
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
