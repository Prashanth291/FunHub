import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/games_dashboard.dart';
import 'screens/home_screen.dart';
import 'screens/guess_number.dart';
import 'screens/quiz_game.dart';
import 'screens/leaderboard.dart';
import 'screens/profile.dart';
import 'screens/daily_challenge.dart';
import 'screens/memory_match.dart';
import 'screens/math_challenge.dart';
import 'screens/emoji_quiz.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const FunHubApp(),
    ),
  );
}

class FunHubApp extends StatelessWidget {
  const FunHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainWrapper(),
      routes: {
        '/games': (context) => const GamesDashboard(),
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

// Main wrapper - handles authentication state
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // If not authenticated, show login screen
        if (!authService.isAuthenticated) {
          return const ProfileScreen(); // Shows AuthScreen inside
        }
        // If authenticated, show games dashboard
        return const GamesDashboard();
      },
    );
  }
}