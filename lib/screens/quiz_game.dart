// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Berlin', 'London', 'Paris', 'Madrid'],
      'answer': 2,
      'icon': Icons.location_city_rounded,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Earth', 'Mars', 'Jupiter', 'Venus'],
      'answer': 1,
      'icon': Icons.public_rounded,
    },
    {
      'question': 'Who wrote "Romeo and Juliet"?',
      'options': ['Charles Dickens', 'William Shakespeare', 'Mark Twain', 'Jane Austen'],
      'answer': 1,
      'icon': Icons.menu_book_rounded,
    },
    {
      'question': 'What is the largest ocean on Earth?',
      'options': ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      'answer': 3,
      'icon': Icons.waves_rounded,
    },
    {
      'question': 'Which element has the chemical symbol O?',
      'options': ['Gold', 'Oxygen', 'Silver', 'Iron'],
      'answer': 1,
      'icon': Icons.science_rounded,
    },
  ];

  int _currentIndex = 0;
  int _score = 0;
  int _selected = -1;
  bool _answered = false;
  bool _quizOver = false;
  int _timer = 15;
  Timer? _timerObj;
  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late AnimationController _timerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  List<Color> _confettiColors = [];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeIn);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _slideController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timerObj?.cancel();
    _slideController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerObj?.cancel();
    setState(() {
      _timer = 15;
    });
    _timerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer == 0) {
        timer.cancel();
        _onTimeUp();
      } else {
        setState(() {
          _timer--;
        });
      }
    });
  }

  void _onTimeUp() {
    setState(() {
      _answered = true;
      _selected = -1;
    });
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _onOptionTap(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == _questions[_currentIndex]['answer']) {
        _score++;
      }
    });
    _timerObj?.cancel();
    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _slideController.reset();
      setState(() {
        _currentIndex++;
        _selected = -1;
        _answered = false;
      });
      _slideController.forward();
      _startTimer();
    } else {
      setState(() {
        _quizOver = true;
      });
      _generateConfetti();
      _confettiController.forward();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selected = -1;
      _answered = false;
      _quizOver = false;
    });
    _slideController.reset();
    _slideController.forward();
    _confettiController.reset();
    _startTimer();
  }

  void _generateConfetti() {
    _confettiColors = List.generate(
      40,
      (index) => [
        Colors.amber,
        Colors.pink,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.red,
        Colors.teal,
      ][Random().nextInt(8)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFFF093FB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background orbs
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              
              // Confetti animation
              if (_quizOver)
                ...List.generate(_confettiColors.length, (index) {
                  final random = Random(index);
                  final startX = random.nextDouble() * size.width;
                  final endY = size.height + 50;
                  final rotation = random.nextDouble() * 2 * pi;
                  return AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      final progress = _confettiController.value;
                      final y = progress * endY;
                      final swing = sin(progress * 6 + rotation) * 40;
                      return Positioned(
                        left: startX + swing,
                        top: y - 50,
                        child: Transform.rotate(
                          angle: progress * 8 + rotation,
                          child: Container(
                            width: random.nextInt(6) + 8,
                            height: random.nextInt(6) + 8,
                            decoration: BoxDecoration(
                              color: _confettiColors[index],
                              shape: random.nextBool() ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius: random.nextBool() ? BorderRadius.circular(2) : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              
              // Main content
              _quizOver ? _buildResult(context) : _buildQuiz(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    
    return Column(
      children: [
        // Header with progress and timer
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '$_score',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Timer with animation
                  AnimatedBuilder(
                    animation: _timer <= 5 ? _timerController : _pulseController,
                    builder: (context, child) => Transform.scale(
                      scale: _timer <= 5 ? 1.0 + (_timerController.value * 0.15) : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _timer <= 5 
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _timer <= 5 ? Colors.red : Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              color: _timer <= 5 ? Colors.red.shade100 : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_timer',
                              style: TextStyle(
                                color: _timer <= 5 ? Colors.red.shade100 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Question card with icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  q['icon'],
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                q['question'],
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Options
                    ...List.generate(q['options'].length, (idx) {
                      final isCorrect = _answered && idx == q['answer'];
                      final isWrong = _answered && idx == _selected && _selected != q['answer'];
                      final isSelected = _selected == idx;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onOptionTap(idx),
                            borderRadius: BorderRadius.circular(20),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withOpacity(0.4)
                                    : isWrong
                                        ? Colors.red.withOpacity(0.4)
                                        : isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green
                                      : isWrong
                                          ? Colors.red
                                          : Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        String.fromCharCode(65 + idx),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        q['options'][idx],
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isCorrect)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green.shade100,
                                        size: 28,
                                      )
                                    else if (isWrong)
                                      Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red.shade100,
                                        size: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final percentage = (_score / _questions.length * 100).round();
    final isPerfect = _score == _questions.length;
    final isGood = percentage >= 60;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon with pulse animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPerfect
                        ? Colors.amber.withOpacity(0.25)
                        : Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: isPerfect ? Colors.amber : Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                   child: Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Result card
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isPerfect ? 'Perfect Score!' : isGood ? 'Well Done!' : 'Good Try!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPerfect
                            ? 'You\'re a genius! 🎉'
                            : isGood
                                ? 'Keep it up! 👏'
                                : 'Practice makes perfect! 💪',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Score',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$_score',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    ' / ${_questions.length}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Play again button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _restartQuiz,
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.95)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 18,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: const Color(0xFF667EEA),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF667EEA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}