// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MathChallengeScreen extends StatefulWidget {
  const MathChallengeScreen({super.key});

  @override
  State<MathChallengeScreen> createState() => _MathChallengeScreenState();
}

enum Difficulty { easy, medium, hard }

class _Question {
  final int a;
  final int b;
  final String operator;
  final int answer;
  late final List<int> options;

  _Question({
    required this.a,
    required this.b,
    required this.operator,
    required this.answer,
  }) {
    final incorrect = <int>{};
    while (incorrect.length < 3) {
      final offset = (Random().nextInt(10) + 1) * (Random().nextBool() ? 1 : -1);
      final opt = answer + offset;
      if (opt != answer) {
        incorrect.add(opt);
      }
    }
    options = [answer, ...incorrect]..shuffle();
  }
}

class _MathChallengeScreenState extends State<MathChallengeScreen>
    with TickerProviderStateMixin {
  Difficulty difficulty = Difficulty.easy;
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  int score = 0;
  int timeLeft = 30;
  Timer? _timer;
  late _Question currentQuestion;
  bool gameActive = true;
  int? bestScore;

  late List<String> operatorPool;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this)
      ..repeat(reverse: true);
    _loadBest();
    _generateQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int get numQuestions {
    switch (difficulty) {
      case Difficulty.easy:
        return 4;
      case Difficulty.medium:
        return 6;
      case Difficulty.hard:
        return 8;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !gameActive) {
        _timer?.cancel();
        return;
      }
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _endGame(won: false);
        }
      });
    });
  }

  void _generateQuestion() {
    operatorPool = difficulty == Difficulty.easy
        ? ['+', '-']
        : difficulty == Difficulty.medium
            ? ['+', '-', '*']
            : ['+', '-', '*', '~/'];

    final op = operatorPool[Random().nextInt(operatorPool.length)];
    int a, b;
    late int answer;

    if (op == '~/') {
      b = Random().nextInt(10) + 2;
      answer = Random().nextInt(10) + 2;
      a = answer * b;
    } else if (op == '*') {
      if (difficulty == Difficulty.medium) {
        a = Random().nextInt(12) + 1;
        b = Random().nextInt(12) + 1;
      } else {
        a = Random().nextInt(15) + 2;
        b = Random().nextInt(15) + 2;
      }
      answer = a * b;
    } else {
      if (difficulty == Difficulty.easy) {
        a = Random().nextInt(20) + 1;
        b = Random().nextInt(20) + 1;
      } else {
        a = Random().nextInt(50) + 1;
        b = Random().nextInt(50) + 1;
      }

      if (op == '+') {
        answer = a + b;
      } else {
        if (difficulty == Difficulty.easy && a < b) {
          final temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
      }
    }

    currentQuestion = _Question(a: a, b: b, operator: op, answer: answer);
  }

  void _answerQuestion(int selected) {
    if (!gameActive) return;

    if (selected == currentQuestion.answer) {
      HapticFeedback.lightImpact();
      setState(() => score++);
      if (score >= numQuestions) {
        _endGame(won: true);
      } else {
        setState(() {
          _generateQuestion();
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      _endGame(won: false);
    }
  }

  void _endGame({bool won = false}) {
    if (!gameActive) return;

    setState(() => gameActive = false);
    _timer?.cancel();

    if (won) {
      _confettiController.play();
      _maybeSaveBest();
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _showResultDialog(won);
    });
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => bestScore = prefs.getInt('math_best_${difficulty.name}'));
  }

  Future<void> _maybeSaveBest() async {
    final prefs = await SharedPreferences.getInstance();
    final currentScore = score;
    if (bestScore == null || currentScore > bestScore!) {
      await prefs.setInt('math_best_${difficulty.name}', currentScore);
      if (!mounted) return;
      setState(() => bestScore = currentScore);
    }
  }

  void _showResultDialog(bool won) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: won
                  ? [Colors.green.shade300, Colors.green.shade700]
                  : [Colors.red.shade300, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(won ? Icons.check_circle : Icons.cancel,
                  size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                won ? 'Perfect!' : 'Game Over',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: $score / $numQuestions',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              if (bestScore != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Best: $bestScore',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetGame();
                  },
                  child: const Text('Try Again',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      gameActive = true;
    });
    _generateQuestion();
    _startTimer();
  }

  void _changeDifficulty(Difficulty d) {
    _timer?.cancel();
    setState(() {
      difficulty = d;
      score = 0;
      timeLeft = 30;
      gameActive = true;
      bestScore = null;
    });
    _loadBest();
    _generateQuestion();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 26),
                        ),
                        const Text(
                          'Math Challenge',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${timeLeft}s',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  timeLeft <= 10 ? Colors.amber : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Difficulty buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: Difficulty.values.map((d) {
                        final isSelected = difficulty == d;
                        return Expanded(
                          child: GestureDetector(
                            onTap: gameActive
                                ? null
                                : () => _changeDifficulty(d),
                            child: Opacity(
                              opacity: gameActive && !isSelected ? 0.5 : 1.0,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white, width: 1.5)
                                      : null,
                                ),
                                child: Text(
                                  d.name[0].toUpperCase() + d.name.substring(1),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF667eea)
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Score display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$score / $numQuestions',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30,
                            width: 0.5,
                            color: Colors.white30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Best Score',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bestScore != null ? '$bestScore' : '—',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Question card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AbsorbPointer(
                          absorbing: !gameActive,
                          child: Opacity(
                            opacity: gameActive ? 1.0 : 0.7,
                            // *** START OF FIX ***
                            child: Column(
                              // Use spaceEvenly to distribute, but the Expanded
                              // grid will now properly fill its slot.
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Question
                                Text(
                                  '${currentQuestion.a} ${currentQuestion.operator.replaceFirst('~/', '÷')} ${currentQuestion.b}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF667eea),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  'What is the answer?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Options grid
                                Expanded(
                                  // Use Expanded to force the grid to fill remaining space
                                  child: LayoutBuilder(
                                    // Use LayoutBuilder to get the constraints
                                    builder: (context, constraints) {
                                      const double crossAxisSpacing = 12;
                                      const double mainAxisSpacing = 12;
                                      const int crossAxisCount = 2;

                                      // Calculate item width
                                      final double itemWidth =
                                          (constraints.maxWidth -
                                                  crossAxisSpacing) /
                                              crossAxisCount;
                                      
                                      // Calculate item height (2 rows)
                                      final double itemHeight =
                                          (constraints.maxHeight -
                                                  mainAxisSpacing) /
                                              2;
                                      
                                      // Calculate aspect ratio (width / height)
                                      // Add a small epsilon to prevent divide by zero
                                      final double aspectRatio =
                                          itemWidth / (itemHeight + 0.001);

                                      return GridView.count(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: mainAxisSpacing,
                                        crossAxisSpacing: crossAxisSpacing,
                                        // Use the dynamically calculated aspect ratio
                                        childAspectRatio: aspectRatio,
                                        children: currentQuestion.options
                                            .map((opt) {
                                          return _buildOptionButton(opt);
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // *** END OF FIX ***
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: gameActive
          ? null
          : FloatingActionButton.extended(
              onPressed: _resetGame,
              label: const Text('Try Again'),
              icon: const Icon(Icons.refresh),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOptionButton(int option) {
    return GestureDetector(
      onTap: gameActive ? () => _answerQuestion(option) : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value;
          return Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade50.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3 + (pulse * 0.2)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1 + (pulse * 0.1)),
                  blurRadius: 8 + (pulse * 4),
                  offset: Offset(0, 2 + (pulse * 2)),
                ),
              ],
            ),
            child: Center(
              child: FittedBox( // Add FittedBox to ensure text fits
                fit: BoxFit.scaleDown,
                child: Padding( // Add padding inside the box
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '$option',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}