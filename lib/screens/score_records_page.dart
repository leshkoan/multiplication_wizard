import 'package:flutter/material.dart';
import 'package:multiplication_wizard/game_logic.dart';

class ScoreRecordsPage extends StatelessWidget {
  static final gameLogic = GameLogic();
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
