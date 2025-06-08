import 'package:flutter/material.dart';
import 'package:gssa_2/screens/home_screen.dart';
import 'package:gssa_2/screens/signin_screen.dart';
import 'package:gssa_2/screens/sigup_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SchoolData())],

      child: const StudentGradeSystemApp(initialRoute: '/signup'),
    ),
  );
}

class StudentGradeSystemApp extends StatelessWidget {
  final String initialRoute;

  const StudentGradeSystemApp({super.key, this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gssa Student Grade System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4facfe),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFe1e5e9), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4facfe), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4facfe),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shadowColor: const Color(0xFF4facfe).withOpacity(0.4),
            elevation: 5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),

      initialRoute: initialRoute,
      routes: {
        '/': (context) => const StudentGradeSystemHomePage(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
