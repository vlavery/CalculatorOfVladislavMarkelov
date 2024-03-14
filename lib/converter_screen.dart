// converter_screen.dart
import 'package:flutter/material.dart';

class ConverterScreen extends StatefulWidget {
  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  double kilometers = 0.0;
  double miles = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Kilometers'),
              onChanged: (value) {
                setState(() {
                  kilometers = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Miles: $miles',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                convert();
              },
              child: Text('Convert'),
            ),
          ],
        ),
      ),
    );
  }

  void convert() {
    setState(() {
      miles = kilometers * 0.621371;
    });
  }
}
