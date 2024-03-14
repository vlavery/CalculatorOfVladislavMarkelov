import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'converter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const CalculatorScreen(),
        '/converter': (context) => ConverterScreen(),
      },
    );
  }
}