import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiplication_wizard/game_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multiplication_wizard/main.dart';

void main() {
  group('MyHomePage State Tests', () {
    late MyHomePageState homePageState;

    setUp(() {
      homePageState = MyHomePageState();
      // Мокаем SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state setup', () {
      expect(homePageState.score, 0);
      expect(homePageState.elapsedSeconds, 0);
      expect(homePageState.gameStarted, false);
      expect(homePageState.isFlipped.length, 8);
      expect(homePageState.isFlipped[0].length, 8);
    });

    test('Game initialization', () {
      homePageState.initializeFlipped();
      expect(homePageState.isFlipped.length, 8);

      int hiddenCount = 0;
      for (var row in homePageState.isFlipped) {
        hiddenCount += row.where((cell) => !cell).length;
      }
      expect(hiddenCount, 10);
    });

    test('Game over detection', () {
      // Все клетки открыты
      homePageState.isFlipped = List.generate(
        8,
        (_) => List.generate(8, (_) => true),
      );
      expect(homePageState.isGameOver(), true);

      // Одна клетка закрыта
      homePageState.isFlipped[3][4] = false;
      expect(homePageState.isGameOver(), false);
    });

    test('Score calculation', () {
      homePageState.score = 5;

      // Тестируем правильный ответ
      homePageState.handleCorrectAnswer(0, 0);
      expect(homePageState.score, 8); // 5 + 3
      expect(homePageState.isFlipped[0][0], true);

      // Тестируем неправильный ответ
      homePageState.handleWrongAnswer();
      expect(homePageState.score, 7); // 8 - 1

      // Проверяем, что счет не уходит в минус
      homePageState.score = 0;
      homePageState.handleWrongAnswer();
      expect(homePageState.score, 0);
    });

    test('Time formatting', () {
      expect(homePageState.formatTime(0), '00:00');
      expect(homePageState.formatTime(5), '00:05');
      expect(homePageState.formatTime(65), '01:05');
      expect(homePageState.formatTime(3600), '60:00');
    });
  });

  group('ScoreRecord Tests', () {
    test('ScoreRecord serialization', () {
      final record = ScoreRecord(name: 'Test', score: 10, time: 60);
      final json = record.toJsonString();
      final decoded = ScoreRecord.fromJson(json);

      expect(decoded.name, 'Test');
      expect(decoded.score, 10);
      expect(decoded.time, 60);
    });

    test('ScoreRecord sorting', () {
      final records = [
        ScoreRecord(name: 'A', score: 10, time: 60),
        ScoreRecord(name: 'B', score: 15, time: 45),
        ScoreRecord(name: 'C', score: 12, time: 60),
      ];

      records.sort((a, b) {
        if (a.time == b.time) return b.score.compareTo(a.score);
        return a.time.compareTo(b.time);
      });

      expect(records[0].name, 'B'); // Лучшее время (45 сек)
      expect(
        records[1].name,
        'C',
      ); // При равном времени (60 сек), выше счет (12 vs 10)
      expect(records[2].name, 'A');
    });
  });

  // Интеграционный тест виджета
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Мастер умножения'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Счет: 0'), findsOneWidget);
  });

  test('Game logic test', () {
    final game = MultiplicationGame();
    game.handleAnswer(0, 0, true);
    expect(game.score, 3);
    expect(game.isFlipped[0][0], true);
  });

  
}
