import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multiplication_wizard/screens/score_records_page.dart';
import 'package:multiplication_wizard/screens/number_picker_page.dart';
import 'package:multiplication_wizard/game_logic.dart';

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
  static final gameLogic = GameLogic();
  // List<List<bool>> _isFlipped = List.generate(
  //   8,
  //   (_) => List.generate(8, (_) => true),
  // );
  // Timer? _timer;
  //int _elapsedSeconds = 0;
  // bool _gameStarted = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    gameLogic.initializeFlipped();
    gameLogic.loadScoreRecords();
    //        setState(() {
    ///!!!
    //        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  // void _initializeFlipped() {
  // final random = Random();
  // List<Point<int>> points = [];
  // while (points.length < 10) {
  //   int row = random.nextInt(8);
  //   int col = random.nextInt(8);
  //   Point<int> newPoint = Point(row, col);
  //   if (!points.contains(newPoint)) {
  //     points.add(newPoint);
  //   }
  // }

  ///!!!   setState(() {
  // _isFlipped = List.generate(8, (_) => List.generate(8, (_) => true));
  // for (var point in points) {
  //   _isFlipped[point.x][point.y] = false;
  // }
  ///!!!    });
  ///}

  @override
  void dispose() {
    gameLogic.timer?.cancel();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!gameLogic.getGameStarted()) {
      gameLogic.startGame();
      gameLogic.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          gameLogic.incTimer();
        });
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<int?> _showNumberPickerDialog(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NumberPickerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (gameLogic.isGameOver()) {
      gameLogic.timer?.cancel();
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя игрока',
                  border: OutlineInputBorder(),
                ),
                focusNode: _nameFocusNode,
                onChanged: (value) {
                  setState(() {
                    gameLogic.setPlayerName(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Счет: ${gameLogic.getScore()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Время: ${_formatTime(gameLogic.getTimer())}',
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
                          gameLogic.colLabels[col].toString(),
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
                          gameLogic.rowLabels[row].toString(),
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
                                _nameFocusNode.unfocus();
                                _startTimer();
                                if (!gameLogic.getIsFlipped(row, col)) {
                                  final expectedResult =
                                      gameLogic.rowLabels[row] *
                                      gameLogic.colLabels[col];
                                  final selectedNumber =
                                      await _showNumberPickerDialog(context);

                                  if (selectedNumber != null) {
                                    if (selectedNumber == expectedResult) {
                                      if (!mounted) return;
                                      setState(() {
                                        gameLogic.setIsFlipped(row, col, true);
                                        gameLogic.incScore();
                                      });
                                    } else {
                                      if (!mounted) return;
                                      _showResultDialog(
                                        'Ошибка!',
                                        'Неправильный ответ. Ожидалось $expectedResult, а вы выбрали $selectedNumber.',
                                        () {
                                          if (!mounted) return;
                                          setState(() {
                                            gameLogic.decScore();
                                          });
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                              child:
                                  gameLogic.getIsFlipped(row, col)
                                      ? Center(
                                        child: Text(
                                          (gameLogic.rowLabels[row] *
                                                  gameLogic.colLabels[col])
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
                              (context) => ScoreRecordsPage(
                                scoreRecords: gameLogic.scoreRecords,
                              ),
                        ),
                      );
                    },
                    child: const Text('Таблица рекордов'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      gameLogic.resetGame();
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
            'Поздравляем! Ваш счет: ${gameLogic.getScore()}. Затраченное время: ${_formatTime(gameLogic.getTimer())}',
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
      gameLogic.resetGame();
    });
  }

  void _saveScore() {
    final playerNameToSave = gameLogic.getPlayerName();
    final newRecord = ScoreRecord(
      name: playerNameToSave.isNotEmpty ? playerNameToSave : 'Безымянный',
      score: gameLogic.getScore(),
      time: gameLogic.getTimer(),
    );

    setState(() {
      gameLogic.scoreRecords.add(newRecord);
      gameLogic.scoreRecords.sort((a, b) {
        if (a.time == b.time) {
          return b.score.compareTo(a.score);
        }
        return a.time.compareTo(b.time);
      });
      if (gameLogic.scoreRecords.length > 10) {
        gameLogic.scoreRecords.removeLast();
      }
    });

    gameLogic.saveScoreRecords();
  }

  void _showWelcomeDialog() {
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
