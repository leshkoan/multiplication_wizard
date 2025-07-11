import 'package:flutter/material.dart';
import 'package:multiplication_wizard/game_logic.dart';

class ScoreRecordsPage extends StatefulWidget {
  //static final gameLogic = GameLogic();
  final GameLogic gameLogic;
  final List<ScoreRecord> scoreRecords;

  const ScoreRecordsPage({
    super.key,
    required this.gameLogic,
    required this.scoreRecords,
  });

  @override
  State<ScoreRecordsPage> createState() => _ScoreRecordsPageState();
}

class _ScoreRecordsPageState extends State<ScoreRecordsPage> {
  @override
  void initState() {
    super.initState();
    widget.gameLogic.loadScoreRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Таблица рекордов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearRecords,
            tooltip: 'Очистить таблицу',
          ),
        ],
      ),
      body: _buildRecordsTable(),
    );
  }

  Future<void> _clearRecords() async {
    final currentContext = context;

    final confirmed =
        await showDialog<bool>(
          context: currentContext,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Очистить таблицу?'),
              content: const Text('Все сохранённые рекорды будут удалены.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Очистить',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() {});
    try {
      await widget.gameLogic.clearRecords();
      setState(() => widget.gameLogic.scoreRecords = []);
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Таблица рекордов очищена'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Ошибка при очистке: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildRecordsTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              widget.gameLogic.scoreRecords.asMap().entries.map<DataRow>((
                entry,
              ) {
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
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
