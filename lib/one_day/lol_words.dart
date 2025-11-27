import 'dart:math';

class LoLWords {
  final String word;
  final String wordEnglish;

  LoLWords(this.word, this.wordEnglish);
}

class LoLWordsFactory {
  static List<LoLWords> words = [
    LoLWords(
        '小狗狗摇着尾巴为你加油呢～', 'The little dog is wagging its tail to cheer you on~'),
    LoLWords('熊熊给你一个大大的拥抱，今天也要加油哦！',
        'The bear gives you a big hug, keep going today!'),
    LoLWords('狗狗说：每一个小进步都值得庆祝呢！',
        'The dog says: Every small progress is worth celebrating!'),
    LoLWords('熊熊在为你鼓掌，你已经做得很棒了！',
        'The bear is clapping for you, you\'re doing great!'),
    LoLWords(
        '小狗狗陪着你一起坚持，慢慢来就好～', 'The little dog is with you, take your time~'),
    LoLWords('熊熊相信你一定能做到，给你温暖的鼓励！',
        'The bear believes you can do it, here\'s warm encouragement!'),
    LoLWords('狗狗和熊熊都在为你加油打气呢！', 'Both the dog and bear are cheering you on!'),
    LoLWords('今天也要像小狗狗一样充满活力哦～', 'Be as energetic as a little dog today~'),
    LoLWords('熊熊的拥抱最温暖，记得好好照顾自己。',
        'The bear\'s hug is the warmest, remember to take care of yourself.'),
    LoLWords(
        '小狗狗和熊熊都为你感到骄傲呢！', 'Both the little dog and bear are proud of you!'),
  ];

  static LoLWords randomWord() {
    return words[Random().nextInt(words.length)];
  }
}
