import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const RauchSimApp());
}

class RauchSimApp extends StatelessWidget {
  const RauchSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RauchSim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7A1A),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
