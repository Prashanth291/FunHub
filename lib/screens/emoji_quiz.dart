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

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF1B5E20)], // Green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Quiz Complete!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              // This will now correctly show "Your Score: X / 10"
              Text(
                'Your Score: $_score / ${_questions.length}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
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
                    Navigator.of(context).pop(); // Close dialog
                    _resetGame();
                  },
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00c6ff), Color(0xFF0072ff)], // Fun blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- Header: Score and Question Number ---
                _buildHeader(),
                const SizedBox(height: 20),

                // --- Question Card ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        child: Text(
                          currentQuestion.emojis,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'What does this mean?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Options ---
                Expanded(
                  child: AbsorbPointer(
                    // Disable buttons after an answer is given
                    absorbing: !_gameInProgress,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        return _buildOptionButton(option);
                      },
                    ),
                  ),
                ),

                // --- Feedback Message ---
                AnimatedOpacity(
                  opacity: _feedbackMessage != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _feedbackMessage ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper Widget to build the top header bar.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Question Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Question',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              // This will now correctly show "X / 10"
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper Widget to build a single answer button.
  Widget _buildOptionButton(String option) {
    // Determine the color based on the game state
    Color buttonColor = Colors.white;
    Color textColor = const Color(0xFF0072ff);
    IconData? icon;

    if (_selectedOption != null) {
      // An answer has been selected
      final bool isCorrect =
          option == _questions[_currentIndex].correctAnswer;
      final bool isSelected = option == _selectedOption;

      if (isCorrect) {
        // This is the correct answer
        buttonColor = Colors.green.shade400;
        textColor = Colors.white;
        icon = Icons.check_circle;
      } else if (isSelected) {
        // This is the incorrect answer the user selected
        buttonColor = Colors.red.shade400; // This typo is now fixed
        textColor = Colors.white;
        icon = Icons.cancel;
      } else {
        // This is an unselected, incorrect option
        buttonColor = Colors.white.withOpacity(0.5);
        textColor = Colors.grey.shade700;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () => _answerQuestion(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  color: textColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}