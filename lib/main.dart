import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Импортируем пакет Firebase Core
import 'calculator_screen.dart';
import 'converter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализируем Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Исправляем определение конструктора

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
