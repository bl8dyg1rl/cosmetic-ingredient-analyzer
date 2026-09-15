import 'package:flutter/material.dart';

import 'screens/home_screen.dart';


void main() {
  runApp(
    const CosmeticAnalyzerApp(),
  );
}


class CosmeticAnalyzerApp
    extends StatelessWidget {

  const CosmeticAnalyzerApp({
    super.key,
  });


  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title:
          'Cosmetic Analyzer',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B63),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFCF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F4),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE0E8E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF176B63),
              width: 2,
            ),
          ),
        ),
      ),

      home:
          const HomeScreen(),
    );
  }
}
