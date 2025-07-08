class GameModel {
  late int score;
  late int elapsedSeconds;
  late String playerName;
  late List<List<bool>> isFlipped;

  GameModel() {
    reset();
    playerName = '';
    isFlipped = List.generate(8, (_) => List.generate(8, (_) => true));
  }

  void reset() {
    score = 0;
    elapsedSeconds = 0;
  }
}
