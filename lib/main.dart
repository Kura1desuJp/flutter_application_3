import 'package:flutter/material.dart';
import 'presentation/screens/auth_screen.dart'; // переконайся, що шлях правильний

void main() {
  runApp(const WeightLossCalendarApp());
}

class WeightLossCalendarApp extends StatelessWidget {
  const WeightLossCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Loss Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(), // Підключаємо AuthScreen
    );
  }
}
