import 'package:flutter/material.dart';

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
