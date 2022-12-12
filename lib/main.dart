import 'package:flutter/material.dart';
import 'package:smart_home/LoginPage.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginPage(title: 'Login Page'),
    );
  }
}