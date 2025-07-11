// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:multiplication_wizard/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  static const scoreIncrement = 3;
  static const scoreDecrement = 1;
  static const countUnknownNumbers = 10;
  static const keySharedPreferences = 'scoreRecords';
  late GameModel gameModel;
  late final List<int> rowLabels;
  late final List<int> colLabels;
  late bool _gameStarted;
  List<ScoreRecord> scoreRecords = [];

  Timer? timer;

  GameLogic() {
    gameModel = GameModel();
    rowLabels = [2, 3, 4, 5, 6, 7, 8, 9];
    colLabels = [2, 3, 4, 5, 6, 7, 8, 9];
    _gameStarted = false;
  }

  int getScore() => gameModel.score;

  void incScore() => gameModel.score += scoreIncrement;

  void decScore() => gameModel.score -= scoreDecrement;

  int getTimer() => gameModel.elapsedSeconds;

  void incTimer() => gameModel.elapsedSeconds++;

  void reset() {
    gameModel.reset();
    _gameStarted = false;
    initializeFlipped();
  }

  void resetGame() {
    gameModel.reset();
    initializeFlipped();
    _gameStarted = false;
    timer?.cancel();
  }

  String getPlayerName() => gameModel.playerName;

  void setPlayerName(String name) => gameModel.playerName = name;

  bool getGameStarted() => _gameStarted;

  void startGame() => _gameStarted = true;

  void initializeFlipped() {
    final random = Random();
    List<Point<int>> points = [];
    while (points.length < countUnknownNumbers) {
      int row = random.nextInt(8);
      int col = random.nextInt(8);
      Point<int> newPoint = Point(row, col);
      if (!points.contains(newPoint)) {
        points.add(newPoint);
      }
    }
    gameModel.isFlipped = List.generate(
      8,
      (_) => List.generate(8, (_) => true),
    );
    for (var point in points) {
      gameModel.isFlipped[point.x][point.y] = false;
    }
  }

  void addScoreRecord(ScoreRecord newRecord) {
    scoreRecords.add(newRecord);
    scoreRecords.sort((a, b) {
      if (a.time == b.time) {
        return b.score.compareTo(a.score);
      }
      return a.time.compareTo(b.time);
    });
    if (scoreRecords.length > 10) {
      scoreRecords.removeLast();
    }
  }

  Future<void> saveScoreRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson =
        scoreRecords.map((record) => record.toJsonString()).toList();
    await prefs.setStringList(keySharedPreferences, recordsJson);
  }

  Future<void> loadScoreRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(keySharedPreferences) ?? [];
    //if (!mounted) return;
    //    setState(() {
    scoreRecords =
        recordsJson.map((json) => ScoreRecord.fromJson(json)).toList();
    scoreRecords.sort((a, b) {
      if (a.time == b.time) {
        return b.score.compareTo(a.score);
      }
      return a.time.compareTo(b.time);
    });
    //   });
  }

  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keySharedPreferences);
  }

  bool getIsFlipped(int row, int col) => gameModel.isFlipped[row][col];

  void setIsFlipped(int row, int col, bool value) =>
      gameModel.isFlipped[row][col] = value;

  bool isGameOver() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (!gameModel.isFlipped[row][col]) {
          return false;
        }
      }
    }
    return true;
  }
}

class ScoreRecord {
  final String name;
  final int score;
  final int time;

  ScoreRecord({required this.name, required this.score, required this.time});

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': score, 'time': time};
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory ScoreRecord.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ScoreRecord(
      name: json['name'] as String,
      score: json['score'] as int,
      time: json['time'] as int,
    );
  }

  @override
  String toString() {
    return 'name: $name, score: $score, time: $time';
  }
}
