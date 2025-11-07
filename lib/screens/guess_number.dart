// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class GuessNumberScreen extends StatefulWidget {
  const GuessNumberScreen({super.key});

  @override
  State<GuessNumberScreen> createState() => _GuessNumberScreenState();
}

class _GuessNumberScreenState extends State<GuessNumberScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late int _targetNumber;
  int _attempts = 0;
  String _feedback = '';
  bool _gameOver = false;
  late AnimationController _animController;
  late AnimationController _pulseController;
  AnimationController? _confettiController;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _slideAnim;
  List<Color> _particleColors = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _slideAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _resetGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    _pulseController.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
      _attempts = 0;
      _feedback = '';
      _gameOver = false;
      _controller.clear();
      _particleColors = [];
    });
    _confettiController?.reset();
  }

  void _checkGuess() {
    if (_gameOver) return;
    final guess = int.tryParse(_controller.text);
    if (guess == null || guess < 1 || guess > 100) {
      setState(() {
        _feedback = 'Please enter a number between 1 and 100';
      });
      _animController.forward(from: 0);
      return;
    }
    setState(() {
      _attempts++;
      if (guess == _targetNumber) {
        _feedback = 'Perfect! You won in $_attempts ${_attempts == 1 ? 'try' : 'tries'}!';
        _gameOver = true;
        _generateConfetti();
  _confettiController?.forward();
        _animController.forward(from: 0);
      } else if (guess < _targetNumber) {
        _feedback = 'Try higher';
        _animController.forward(from: 0);
      } else {
        _feedback = 'Try lower';
        _animController.forward(from: 0);
      }
    });
  }

  void _generateConfetti() {
    _particleColors = List.generate(
      30,
      (index) => [
        Colors.amber,
        Colors.pink,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
      ][Random().nextInt(6)],
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
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              
              // Confetti effect
              if (_gameOver && _confettiController != null)
                ...List.generate(_particleColors.length, (index) {
                  final random = Random(index);
                  final startX = random.nextDouble() * size.width;
                  final endY = size.height;
                  return AnimatedBuilder(
                    animation: _confettiController!,
                    builder: (context, child) {
                      final progress = _confettiController!.value;
                      final y = progress * endY;
                      final rotation = progress * 4 * pi;
                      return Positioned(
                        left: startX + sin(progress * 4) * 50,
                        top: y,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _particleColors[index],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              
              // Main content
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Guess Game',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '$_attempts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with animation
                            AnimatedBuilder(
                              animation: _gameOver ? _scaleAnim : _pulseAnim,
                              builder: (context, child) => Transform.scale(
                                scale: _gameOver ? _scaleAnim.value : _pulseAnim.value,
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _gameOver ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                                    size: 80,
                                    color: _gameOver ? Colors.amber : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Title with glassmorphism card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _gameOver ? '🎉 Victory!' : 'Guess the Number',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _gameOver ? 'Congratulations!' : 'Between 1 and 100',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Input field with glassmorphism
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    enabled: !_gameOver,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '?',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 32,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 24,
                                      ),
                                    ),
                                    onSubmitted: (_) => _checkGuess(),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Guess button
                            if (!_gameOver)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _checkGuess,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.white.withOpacity(0.9)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
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
                                            Icons.check_circle_rounded,
                                            color: const Color(0xFF6366F1),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Check',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // Feedback with animation
                            AnimatedBuilder(
                              animation: _slideAnim,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(0, 20 * (1 - _slideAnim.value)),
                                child: Opacity(
                                  opacity: _slideAnim.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _gameOver
                                          ? Colors.amber.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _gameOver
                                            ? Colors.amber.withOpacity(0.5)
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _feedback,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            if (_gameOver) ...[
                              const SizedBox(height: 24),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _resetGame,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Play Again',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}