import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/guess_number.dart';
import 'screens/quiz_game.dart';
import 'screens/daily_challenge.dart';
import 'screens/memory_match.dart';
import 'screens/math_challenge.dart';
import 'screens/emoji_quiz.dart';

void main() {
  runApp(const FunHubApp());
}

class FunHubApp extends StatelessWidget {
  const FunHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomeScreen(),
        '/guess': (context) => const GuessNumberScreen(),
        '/quiz': (context) => const QuizGameScreen(),
        '/daily': (context) => const DailyChallengeScreen(),
        '/memory': (context) => const MemoryMatchScreen(),
        '/math': (context) => const MathChallengeScreen(),
        '/emoji': (context) => const EmojiQuizScreen(),
      },
    );
  }
}
