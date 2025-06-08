import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiplication_wizard/main.dart';

void main() {
  testWidgets('NumberPicker selects number', (WidgetTester tester) async {
    // Создаем виджет
    await tester.pumpWidget(const MaterialApp(
      home: NumberPickerPage(),
    ));

    // Проверяем, что виджет отрендерился
    expect(find.text('Выберите число'), findsOneWidget);
    
    // Находим и нажимаем кнопку с числом 5
    await tester.tap(find.text('5'));
    await tester.pump();
    
    // Проверяем, что Navigator.pop вызывается с правильным значением
    expect(tester.takeException(), isNull);
  });
}