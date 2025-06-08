import 'dart:math';

class MultiplicationGame {
  final List<int> rowLabels;
  final List<int> colLabels;
  List<List<bool>> isFlipped;
  int score = 0;
  int elapsedSeconds = 0;
  bool gameStarted = false;

  MultiplicationGame({
    this.rowLabels = const [2, 3, 4, 5, 6, 7, 8, 9],
    this.colLabels = const [2, 3, 4, 5, 6, 7, 8, 9],
  }) : isFlipped = List.generate(8, (_) => List.filled(8, true)) {
    _initializeFlipped();
  }

  void _initializeFlipped() {
    final random = Random();
    final points = <Point<int>>{};

    while (points.length < 10) {
      points.add(Point(random.nextInt(8), random.nextInt(8)));
    }

    isFlipped = List.generate(8, (_) => List.filled(8, true));
    for (final point in points) {
      isFlipped[point.x][point.y] = false;
    }
  }

  void handleAnswer(int row, int col, int selectedNumber) {
    final expectedResult = rowLabels[row] * colLabels[col];
    if (selectedNumber == expectedResult) {
      isFlipped[row][col] = true;
      score += 3;
    } else {
      score = max(0, score - 1);
    }
  }

  bool get isGameOver => isFlipped.every((row) => row.every((cell) => cell));

  void reset() {
    score = 0;
    elapsedSeconds = 0;
    gameStarted = false;
    _initializeFlipped();
  }

  String formatTime() {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}