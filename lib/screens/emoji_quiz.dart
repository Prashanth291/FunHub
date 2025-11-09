// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

// --- 1. Data Model ---
/// A class to hold the data for a single emoji question.
class EmojiQuestion {
  final String emojis;
  final String correctAnswer;
  final List<String> options;

  EmojiQuestion({
    required this.emojis,
    required this.correctAnswer,
    required this.options,
  }) {
    // Ensure options are shuffled for variety
    options.shuffle();
  }
}

// --- 2. Game Data ---
/// The list of all questions for the quiz.
/// This is kept outside the State class for efficiency.
final List<EmojiQuestion> _allQuestions = [
  // --- Movies (15) ---
  EmojiQuestion(
    emojis: '🦁👑',
    correctAnswer: 'The Lion King',
    options: ['The Lion King', 'Madagascar', 'The Jungle Book', 'Zootopia'],
  ),
  EmojiQuestion(
    emojis: '🥶👸',
    correctAnswer: 'Frozen',
    options: ['Frozen', 'Tangled', 'Moana', 'Cinderella'],
  ),
  EmojiQuestion(
    emojis: '🕷️👨',
    correctAnswer: 'Spider-Man',
    options: ['Spider-Man', 'Batman', 'Superman', 'Iron Man'],
  ),
  EmojiQuestion(
    emojis: '🧙‍♂️🚂✨',
    correctAnswer: 'Harry Potter',
    options: ['Harry Potter', 'Lord of the Rings', 'Narnia', 'Percy Jackson'],
  ),
  EmojiQuestion(
    emojis: '🚗💨🏁',
    correctAnswer: 'Fast & Furious',
    options: ['Fast & Furious', 'Cars', 'Need for Speed', 'Gone in 60 Seconds'],
  ),
  EmojiQuestion(
    emojis: '🚢🧊💔',
    correctAnswer: 'Titanic',
    options: ['Titanic', 'The Poseidon Adventure', 'Waterworld', 'Jaws'],
  ),
  EmojiQuestion(
    emojis: 'UP',
    correctAnswer: 'Up',
    options: ['Up', 'Inside Out', 'Toy Story', 'Ratatouille'],
  ),
  EmojiQuestion(
    emojis: '⭐⚔️',
    correctAnswer: 'Star Wars',
    options: ['Star Wars', 'Star Trek', 'Guardians of the Galaxy', 'Dune'],
  ),
  EmojiQuestion(
    emojis: '🦖🏞️',
    correctAnswer: 'Jurassic Park',
    options: ['Jurassic Park', 'Godzilla', 'King Kong', 'The Land Before Time'],
  ),
  EmojiQuestion(
    emojis: '👻🔫',
    correctAnswer: 'Ghostbusters',
    options: ['Ghostbusters', 'Men in Black', 'Beetlejuice', 'Casper'],
  ),
  EmojiQuestion(
    emojis: 'finding nemo',
    correctAnswer: 'Finding Nemo',
    options: ['Finding Nemo', 'Shark Tale', 'The Little Mermaid', 'Moana'],
  ),
  EmojiQuestion(
    emojis: '🧑‍🚀🌌',
    correctAnswer: 'Interstellar',
    options: ['Interstellar', 'Gravity', 'The Martian', 'Apollo 13'],
  ),
  EmojiQuestion(
    emojis: '🍫🏭',
    correctAnswer: 'Willy Wonka',
    options: ['Willy Wonka', 'Charlie & the Chocolate Factory', 'Chitty Chitty Bang Bang', 'Elf'],
  ),
  EmojiQuestion(
    emojis: 'fight club',
    correctAnswer: 'Fight Club',
    options: ['Fight Club', 'Rocky', 'Creed', 'Million Dollar Baby'],
  ),
  EmojiQuestion(
    emojis: 'back to the future',
    correctAnswer: 'Back to the Future',
    options: ['Back to the Future', 'The Terminator', 'Bill & Ted', 'Doctor Who'],
  ),

  // --- TV Shows (10) ---
  EmojiQuestion(
    emojis: '🍍🏠🌊',
    correctAnswer: 'SpongeBob',
    options: ['SpongeBob', 'Finding Nemo', 'Moana', 'Lilo & Stitch'],
  ),
  EmojiQuestion(
    emojis: '🧑‍🔬⚗️💥',
    correctAnswer: 'Breaking Bad',
    options: ['Breaking Bad', 'Dexter', 'The Big Bang Theory', 'Chernobyl'],
  ),
  EmojiQuestion(
    emojis: '🦇🃏',
    correctAnswer: 'Batman',
    options: ['Batman', 'Joker', 'Gotham', 'The Dark Knight'],
  ),
  EmojiQuestion(
    emojis: '🐉👑⚔️',
    correctAnswer: 'Game of Thrones',
    options: ['Game of Thrones', 'The Witcher', 'Vikings', 'Lord of the Rings'],
  ),
  EmojiQuestion(
    emojis: 'friends',
    correctAnswer: 'Friends',
    options: ['Friends', 'Seinfeld', 'How I Met Your Mother', 'The Office'],
  ),
  EmojiQuestion(
    emojis: '👽🚲',
    correctAnswer: 'Stranger Things',
    options: ['Stranger Things', 'E.T.', 'The Goonies', 'Super 8'],
  ),
  EmojiQuestion(
    emojis: 'the walking dead',
    correctAnswer: 'The Walking Dead',
    options: ['The Walking Dead', 'Z Nation', 'The Last of Us', 'Resident Evil'],
  ),
  EmojiQuestion(
    emojis: 'office',
    correctAnswer: 'The Office',
    options: ['The Office', 'Parks and Recreation', '30 Rock', 'Silicon Valley'],
  ),
  EmojiQuestion(
    emojis: '👑🇬🇧',
    correctAnswer: 'The Crown',
    options: ['The Crown', 'Downton Abbey', 'Bridgerton', 'Victoria'],
  ),
  EmojiQuestion(
    emojis: 'money heist',
    correctAnswer: 'Money Heist',
    options: ['Money Heist', 'Lupin', 'Prison Break', 'Ocean\'s Eleven'],
  ),

  // --- Phrases / Objects / Places (15) ---
  EmojiQuestion(
    emojis: '🥞',
    correctAnswer: 'Pancakes',
    options: ['Pancakes', 'Waffles', 'Cookies', 'Bread'],
  ),
  EmojiQuestion(
    emojis: '☕️📖',
    correctAnswer: 'Reading a book',
    options: ['Reading a book', 'Coffee break', 'Morning news', 'Homework'],
  ),
  EmojiQuestion(
    emojis: ' rained cats and dogs',
    correctAnswer: 'Raining cats and dogs',
    options: ['Raining cats and dogs', 'Pet store', 'Animal shelter', 'It\'s raining'],
  ),
  EmojiQuestion(
    emojis: '📱🔋🔌',
    correctAnswer: 'Charging phone',
    options: ['Charging phone', 'Low battery', 'New phone', 'Power outage'],
  ),
  EmojiQuestion(
    emojis: '🍕📺',
    correctAnswer: 'Pizza and movie',
    options: ['Pizza and movie', 'Netflix', 'Ordering food', 'Dinner date'],
  ),
  EmojiQuestion(
    emojis: '🚀🌕',
    correctAnswer: 'To the moon',
    options: ['To the moon', 'Space travel', 'Rocket launch', 'Astronomy'],
  ),
  EmojiQuestion(
    emojis: '🗽🇺🇸',
    correctAnswer: 'Statue of Liberty',
    options: ['Statue of Liberty', 'New York', 'USA', 'Empire State Building'],
  ),
  EmojiQuestion(
    emojis: '🗼🇫🇷',
    correctAnswer: 'Eiffel Tower',
    options: ['Eiffel Tower', 'Paris', 'France', 'Arc de Triomphe'],
  ),
  EmojiQuestion(
    emojis: '🎂🎉🥳',
    correctAnswer: 'Birthday party',
    options: ['Birthday party', 'New Year\'s Eve', 'Wedding', 'Graduation'],
  ),
  EmojiQuestion(
    emojis: '😴⏰',
    correctAnswer: 'Alarm clock',
    options: ['Alarm clock', 'Waking up', 'Going to bed', 'Time is running out'],
  ),
  EmojiQuestion(
    emojis: '🤯',
    correctAnswer: 'Mind blown',
    options: ['Mind blown', 'Headache', 'Explosion', 'Thinking hard'],
  ),
  EmojiQuestion(
    emojis: '🎸🧑‍🎤',
    correctAnswer: 'Rockstar',
    options: ['Rockstar', 'Guitar lesson', 'Concert', 'Singing'],
  ),
  EmojiQuestion(
    emojis: 'break a leg',
    correctAnswer: 'Break a leg',
    options: ['Break a leg', 'Good luck', 'Hospital', 'Broken bone'],
  ),
  EmojiQuestion(
    emojis: '🍔🍟',
    correctAnswer: 'Burger and fries',
    options: ['Burger and fries', 'Fast food', 'McDonald\'s', 'Lunch time'],
  ),
  EmojiQuestion(
    emojis: 'easy as pie',
    correctAnswer: 'Easy as pie',
    options: ['Easy as pie', 'Baking', 'Simple math', 'Dessert'],
  ),
];


// --- 3. Main Widget ---
class EmojiQuizScreen extends StatefulWidget {
  const EmojiQuizScreen({super.key});

  @override
  State<EmojiQuizScreen> createState() => _EmojiQuizScreenState();
}

class _EmojiQuizScreenState extends State<EmojiQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _gameInProgress = true;
  String? _feedbackMessage;
  String? _selectedOption;

  // We'll shuffle the questions at the start of each game
  late List<EmojiQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  /// Shuffles questions and resets all game state variables.
  void _resetGame() {
    setState(() {
      _questions = ([..._allQuestions]..shuffle()).take(10).toList();

      _currentIndex = 0;
      _score = 0;
      _gameInProgress = true;
      _feedbackMessage = null;
      _selectedOption = null;
    });
  }

  /// Handles logic when an answer button is tapped.
  void _answerQuestion(String selectedAnswer) {
    if (!_gameInProgress) return; // Don't allow multiple taps

    final bool isCorrect =
        selectedAnswer == _questions[_currentIndex].correctAnswer;

    setState(() {
      _gameInProgress = false; // Lock answers
      _selectedOption = selectedAnswer; // Show which option was tapped

      if (isCorrect) {
        _score++;
        _feedbackMessage = 'Correct!';
        HapticFeedback.lightImpact();
      } else {
        _feedbackMessage =
            'Wrong! It was: ${_questions[_currentIndex].correctAnswer}';
        HapticFeedback.heavyImpact();
      }
    });

    // Wait for a moment, then move to the next question or end game
    Timer(const Duration(milliseconds: 1500), () {
      _nextQuestion();
    });
  }

  /// Moves to the next question or ends the game.
  void _nextQuestion() {
    setState(() {
      // This logic works perfectly, as _questions.length is now 10.
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _gameInProgress = true;
        _feedbackMessage = null;
        _selectedOption = null;
      } else {
        _endGame();
      }
    });
  }

  /// Shows the final result dialog.
  void _endGame() {
    setState(() {
      _gameInProgress = false; // Ensure game is fully stopped
    });

    final percentage = (_score / _questions.length * 100).round();
    final isPerfect = _score == _questions.length;
    final isGood = percentage >= 60;

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
              // Trophy icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                        : isGood
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPerfect
                              ? const Color(0xFFF59E0B)
                              : isGood
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6366F1))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                isPerfect ? 'Perfect Score!' : isGood ? 'Well Done!' : 'Good Try!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                isPerfect
                    ? 'You\'re an emoji expert! 🎉'
                    : isGood
                        ? 'Great job! 👏'
                        : 'Keep practicing! 💪',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Score display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                        : isGood
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isPerfect
                              ? const Color(0xFFF59E0B)
                              : isGood
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6366F1))
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$_score',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            ' / ${_questions.length}',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Play Again button
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
                        'Play Again',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current question safely
    final EmojiQuestion currentQuestion = _questions[_currentIndex];

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
              child: const Icon(Icons.emoji_emotions_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Emoji Quiz',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
            ),
            child: Text(
              '${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(width: 12),
                    const Text(
                      'Score: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Emoji display
              Container(
                width: 160,
                height: 160,
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
                child: Center(
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        currentQuestion.emojis,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Question text card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'What does this emoji mean?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options
              AbsorbPointer(
                absorbing: !_gameInProgress,
                child: Column(
                  children: currentQuestion.options.map((option) {
                    return _buildOptionButton(option);
                  }).toList(),
                ),
              ),

              // Feedback Message
              AnimatedOpacity(
                opacity: _feedbackMessage != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _feedbackMessage?.contains('Correct') ?? false
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _feedbackMessage ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Widget to build a single answer button.
  Widget _buildOptionButton(String option) {
    // Determine the color based on the game state
    Color buttonColor = Colors.white;
    Color textColor = const Color(0xFF1E293B);
    Color borderColor = Colors.grey[300]!;
    IconData? icon;

    if (_selectedOption != null) {
      // An answer has been selected
      final bool isCorrect =
          option == _questions[_currentIndex].correctAnswer;
      final bool isSelected = option == _selectedOption;

      if (isCorrect) {
        // This is the correct answer
        buttonColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF1E293B);
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        // This is the incorrect answer the user selected
        buttonColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF1E293B);
        icon = Icons.cancel_rounded;
      } else {
        // This is an unselected, incorrect option
        buttonColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
        textColor = const Color(0xFF64748B);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _answerQuestion(option),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (_selectedOption == null || option == _selectedOption || 
                    option == _questions[_currentIndex].correctAnswer)
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: icon == Icons.check_circle_rounded 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFEF4444),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}