import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/guess_number.dart';
import 'screens/quiz_game.dart';
import 'screens/leaderboard.dart';
import 'screens/profile.dart';
import 'screens/daily_challenge.dart';
import 'screens/memory_match.dart';
import 'screens/math_challenge.dart';
import 'screens/emoji_quiz.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomeScreen(),
        '/guess': (context) => const GuessNumberScreen(),
        '/quiz': (context) => const QuizGameScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/daily': (context) => const DailyChallengeScreen(),
        '/memory': (context) => const MemoryMatchScreen(),
        '/math': (context) => const MathChallengeScreen(),
        '/emoji': (context) => const EmojiQuizScreen(),
      },
    );
  }
}
