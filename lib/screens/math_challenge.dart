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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: won
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (won ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  won ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                won ? 'Perfect!' : 'Game Over',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Score card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: won
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (won ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                          .withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            ' / $numQuestions',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (bestScore != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Best: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$bestScore',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Try Again button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetGame();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Math Challenge',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Timer badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timeLeft <= 10 
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: timeLeft <= 10 
                    ? Colors.red.withOpacity(0.3)
                    : const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: timeLeft <= 10 ? Colors.red : const Color(0xFF6366F1),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${timeLeft}s',
                  style: TextStyle(
                    color: timeLeft <= 10 ? Colors.red : const Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Difficulty selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: Difficulty.values.map((d) {
                        final isSelected = difficulty == d;
                        return Expanded(
                          child: GestureDetector(
                            onTap: gameActive ? null : () => _changeDifficulty(d),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                d.name[0].toUpperCase() + d.name.substring(1),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Score card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$score / $numQuestions',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Best',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bestScore != null ? '$bestScore' : '—',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Calculator icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AbsorbPointer(
                      absorbing: !gameActive,
                      child: Opacity(
                        opacity: gameActive ? 1.0 : 0.5,
                        child: Column(
                          children: [
                            // Question
                            Text(
                              '${currentQuestion.a} ${currentQuestion.operator.replaceFirst('~/', '÷')} ${currentQuestion.b}',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Tap the correct answer',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Options - Vertical list
                            ...currentQuestion.options.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOptionButton(entry.value),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
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
                  Color(0xFF10B981),
                  Color(0xFF6366F1),
                  Color(0xFFEC4899),
                  Color(0xFFF59E0B),
                  Color(0xFF8B5CF6),
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 20,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: gameActive
          ? null
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: FloatingActionButton.extended(
                onPressed: _resetGame,
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 8,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOptionButton(int option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: gameActive ? () => _answerQuestion(option) : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = _pulseController.value;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.08 + (pulse * 0.05)),
                    const Color(0xFF8B5CF6).withOpacity(0.08 + (pulse * 0.05)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.4 + (pulse * 0.15)),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.15 + (pulse * 0.1)),
                    blurRadius: 8 + (pulse * 4),
                    offset: Offset(0, 2 + (pulse * 2)),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$option',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}