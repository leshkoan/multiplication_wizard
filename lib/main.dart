import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiplication_wizard/game_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мастер умножения',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          toolbarHeight: 30,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final MultiplicationGame game;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    game = MultiplicationGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  Future<void> loadScoreRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList('scoreRecords') ?? [];
    if (!mounted) return;
    setState(() {
      scoreRecords =
          recordsJson.map((json) => ScoreRecord.fromJson(json)).toList();
      scoreRecords.sort((a, b) {
        if (a.time == b.time) {
          return b.score.compareTo(a.score);
        }
        return a.time.compareTo(b.time);
      });
    });
  }

  Future<void> saveScoreRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson =
        scoreRecords.map((record) => record.toJsonString()).toList();
    await prefs.setStringList('scoreRecords', recordsJson);
  }

  void initializeFlipped() {
    final random = Random();
    List<Point<int>> points = [];
    while (points.length < 10) {
      int row = random.nextInt(8);
      int col = random.nextInt(8);
      Point<int> newPoint = Point(row, col);
      if (!points.contains(newPoint)) {
        points.add(newPoint);
      }
    }

    setState(() {
      isFlipped = List.generate(8, (_) => List.generate(8, (_) => true));
      for (var point in points) {
        isFlipped[point.x][point.y] = false;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    if (!gameStarted) {
      gameStarted = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          elapsedSeconds++;
        });
      });
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  bool isGameOver() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (!isFlipped[row][col]) {
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    setState(() {
      score = 0;
      isFlipped = List.generate(8, (_) => List.generate(8, (_) => true));
      initializeFlipped();
      elapsedSeconds = 0;
      gameStarted = false;
      timer?.cancel();
    });
  }

  Future<int?> showNumberPickerDialog(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NumberPickerPage()),
    );
  }

  void handleCorrectAnswer(int row, int col) {
    setState(() {
      isFlipped[row][col] = true;
      score += 3;
    });
  }

  void handleWrongAnswer() {
    setState(() {
      score -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isGameOver()) {
      timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мастер умножения')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя игрока',
                  border: OutlineInputBorder(),
                ),
                focusNode: nameFocusNode,
                onChanged: (value) {
                  setState(() {
                    playerName = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Счет: $score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Время: ${formatTime(elapsedSeconds)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 20),
                  for (int col = 0; col < 8; col++)
                    Expanded(
                      child: Center(
                        child: Text(
                          colLabels[col].toString(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
              for (int row = 0; row < 8; row++)
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: Text(
                          rowLabels[row].toString(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    for (int col = 0; col < 8; col++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () async {
                                nameFocusNode.unfocus();
                                startTimer();
                                if (!isFlipped[row][col]) {
                                  final expectedResult =
                                      rowLabels[row] * colLabels[col];
                                  final selectedNumber =
                                      await showNumberPickerDialog(context);

                                  if (selectedNumber != null) {
                                    if (selectedNumber == expectedResult) {
                                      handleCorrectAnswer(row, col);
                                    } else {
                                      if (!mounted) return;
                                      _showResultDialog(
                                        'Ошибка!',
                                        'Неправильный ответ. Ожидалось $expectedResult, а вы выбрали $selectedNumber.',
                                        handleWrongAnswer,
                                      );
                                    }
                                  }
                                }
                              },
                              child:
                                  isFlipped[row][col]
                                      ? Center(
                                        child: Text(
                                          (rowLabels[row] * colLabels[col])
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ScoreRecordsPage(scoreRecords: scoreRecords),
                        ),
                      );
                    },
                    child: const Text('Таблица рекордов'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      resetGame();
                    },
                    child: const Text('Начать заново'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(String title, String content, VoidCallback onOk) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                onOk();
              },
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Игра окончена!'),
          content: Text(
            'Поздравляем! Ваш счет: $score. Затраченное время: ${formatTime(elapsedSeconds)}',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      _saveScore();
      resetGame();
    });
  }

  void _saveScore() {
    final newRecord = ScoreRecord(
      name: playerName.isNotEmpty ? playerName : 'Безымянный',
      score: score,
      time: elapsedSeconds,
    );

    setState(() {
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
    });

    saveScoreRecords();
  }

  void showWelcomeDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добро пожаловать!'),
          content: const Text(
            'Заполни недостающие результаты в таблице умножения',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Начать'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class NumberPickerPage extends StatelessWidget {
  const NumberPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите число')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.5,
        ),
        itemCount: 98,
        itemBuilder: (BuildContext context, int index) {
          final number = index + 2;
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontSize: 20),
                side:
                    number % 10 == 0
                        ? const BorderSide(color: Colors.red, width: 2)
                        : null,
              ),
              onPressed: () {
                Navigator.of(context).pop(number);
              },
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
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

class ScoreRecordsPage extends StatelessWidget {
  final List<ScoreRecord> scoreRecords;

  const ScoreRecordsPage({super.key, required this.scoreRecords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Таблица рекордов')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Место')),
              DataColumn(label: Text('Имя')),
              DataColumn(label: Text('Счет')),
              DataColumn(label: Text('Время')),
            ],
            rows:
                scoreRecords.asMap().entries.map<DataRow>((entry) {
                  int index = entry.key;
                  ScoreRecord record = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(record.name)),
                      DataCell(Text(record.score.toString())),
                      DataCell(Text(_formatTime(record.time))),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
