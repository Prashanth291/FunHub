// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ENUMS for State Management ---

enum _ChallengeState { loading, start, playing, completed }

enum QuestionType { math, trivia, emoji }

// --- Data Model ---

class _Question {
  final QuestionType type;
  final String question;
  final List<String> options;
  final int correctIndex;

  _Question({
    required this.type,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// --- Main Widget ---

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _progressController;

  // State Management
  _ChallengeState _challengeState = _ChallengeState.loading;
  late Future<void> _loadFuture;
  bool gameActive = false; // Used for timer and delay guards
  
  // Game Data
  List<_Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 60;
  Timer? _timer;

  // Daily Stats
  bool alreadyCompletedToday = false;
  int? todaysBestScore;
  int streak = 0;
  
  // UI State
  String? selectedAnswer;
  bool showFeedback = false;

  // --- Question Pools (Expanded) ---

  final List<Map<String, dynamic>> _triviaPool = [
    {'q': 'What is the capital of France?', 'a': 'Paris', 'w': ['London', 'Berlin', 'Madrid']},
    {'q': 'How many continents are there?', 'a': '7', 'w': ['5', '6', '8']},
    {'q': 'Which planet is known as the Red Planet?', 'a': 'Mars', 'w': ['Venus', 'Jupiter', 'Saturn']},
    {'q': 'What is the largest ocean?', 'a': 'Pacific', 'w': ['Atlantic', 'Indian', 'Arctic']},
    {'q': 'What is the boiling point of water?', 'a': '100°C', 'w': ['90°C', '0°C', '212°F']},
    {'q': 'Who wrote "Hamlet"?', 'a': 'Shakespeare', 'w': ['Dickens', 'Tolkien', 'Hemingway']},
    {'q': 'What is the tallest mammal?', 'a': 'Giraffe', 'w': ['Elephant', 'Blue Whale', 'Hippo']},
    {'q': 'What is the primary language of Brazil?', 'a': 'Portuguese', 'w': ['Spanish', 'Brazilian', 'English']},
    {'q': 'How many legs does a spider have?', 'a': '8', 'w': ['6', '10', '4']},
    {'q': 'What is H2O?', 'a': 'Water', 'w': ['Hydrogen Peroxide', 'Salt', 'Sugar']},
    {'q': 'Which country is home to the kangaroo?', 'a': 'Australia', 'w': ['Austria', 'New Zealand', 'South Africa']},
    {'q': 'Who painted the Mona Lisa?', 'a': 'Da Vinci', 'w': ['Picasso', 'Van Gogh', 'Monet']},
    {'q': 'What is the currency of Japan?', 'a': 'Yen', 'w': ['Won', 'Yuan', 'Dollar']},
    {'q': 'How many sides does a triangle have?', 'a': '3', 'w': ['4', '5', '2']},
    {'q': 'What is the fastest land animal?', 'a': 'Cheetah', 'w': ['Lion', 'Ostrich', 'Horse']},
    {'q': 'What is the main ingredient in guacamole?', 'a': 'Avocado', 'w': ['Tomato', 'Onion', 'Lime']},
    {'q': 'In what year did the Titanic sink?', 'a': '1912', 'w': ['1905', '1920', '1898']},
    {'q': 'What is the "Big Apple"?', 'a': 'New York City', 'w': ['A large apple', 'Los Angeles', 'Apple Inc.']},
    {'q': 'What is the square root of 64?', 'a': '8', 'w': ['6', '7', '9']},
    {'q': 'Which is the largest planet?', 'a': 'Jupiter', 'w': ['Saturn', 'Neptune', 'Earth']},
  ];

  final List<Map<String, dynamic>> _emojiPool = [
    {'q': '🍎', 'a': 'Apple', 'w': ['Orange', 'Banana', 'Grapes']},
    {'q': '🐶', 'a': 'Dog', 'w': ['Cat', 'Bird', 'Fish']},
    {'q': '🚗', 'a': 'Car', 'w': ['Bike', 'Bus', 'Train']},
    {'q': '⚽', 'a': 'Soccer', 'w': ['Basketball', 'Tennis', 'Baseball']},
    {'q': '🏠', 'a': 'House', 'w': ['School', 'Office', 'Hospital']},
    {'q': '🌞', 'a': 'Sun', 'w': ['Moon', 'Star', 'Cloud']},
    {'q': '📚', 'a': 'Books', 'w': ['Pen', 'Pencil', 'Paper']},
    {'q': '🎂', 'a': 'Cake', 'w': ['Pizza', 'Burger', 'Pasta']},
    {'q': '🦁👑', 'a': 'The Lion King', 'w': ['Madagascar', 'Jungle Book', 'Zootopia']},
    {'q': '🕷️👨', 'a': 'Spider-Man', 'w': ['Batman', 'Superman', 'Iron Man']},
    {'q': '🚢🧊', 'a': 'Titanic', 'w': ['Jaws', 'Waterworld', 'Poseidon']},
    {'q': '🧙‍♂️🚂', 'a': 'Harry Potter', 'w': ['Lord of the Rings', 'Narnia', 'Merlin']},
    {'q': '🍍🏠', 'a': 'SpongeBob', 'w': ['Finding Nemo', 'Moana', 'Lilo & Stitch']},
    {'q': '🦇🃏', 'a': 'Batman', 'w': ['Joker', 'Gotham', 'The Dark Knight']},
    {'q': '🍔🍟', 'a': 'Burger & Fries', 'w': ['Hotdog & Soda', 'Pizza & Salad', 'Taco & Nachos']},
    {'q': '🚀🌕', 'a': 'To the moon', 'w': ['Space travel', 'Alien', 'Rocket launch']},
    {'q': '🗼🇫🇷', 'a': 'Eiffel Tower', 'w': ['Statue of Liberty', 'Big Ben', 'Pisa Tower']},
    {'q': ' rained cats and dogs', 'a': 'Raining cats & dogs', 'w': ['Pet store', 'Animal shelter', 'Raining lightly']},
    {'q': 'break a leg', 'a': 'Break a leg', 'w': ['Good luck', 'Hospital', 'Broken bone']},
    {'q': '👻🔫', 'a': 'Ghostbusters', 'w': ['Men in Black', 'Beetlejuice', 'Casper']},
  ];

  // --- Lifecycle Methods ---

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Use a Future to manage async loading
    _loadFuture = _checkTodayCompletion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // --- Game State Logic ---

  Future<void> _checkTodayCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    final completedKey = 'daily_completed_$todayKey';
    final scoreKey = 'daily_score_$todayKey';
    final streakKey = 'daily_streak';

    // This runs *before* setting state
    final hasCompleted = prefs.getBool(completedKey) ?? false;
    
    setState(() {
      alreadyCompletedToday = hasCompleted;
      todaysBestScore = prefs.getInt(scoreKey);
      streak = prefs.getInt(streakKey) ?? 0;
      _challengeState = alreadyCompletedToday ? _ChallengeState.completed : _ChallengeState.start;
    });
  }

  void _startChallenge() {
    _generateDailyQuestions();
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      timeLeft = 60;
      gameActive = true;
      selectedAnswer = null;
      showFeedback = false;
      _challengeState = _ChallengeState.playing;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Ensure no duplicates
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !gameActive) {
        _timer?.cancel();
        return;
      }
      
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _answerQuestion(int selectedIndex) {
    if (!gameActive || showFeedback) return;

    final isCorrect = selectedIndex == questions[currentQuestionIndex].correctIndex;
    
    setState(() {
      selectedAnswer = questions[currentQuestionIndex].options[selectedIndex];
      showFeedback = true;
      if (isCorrect) score++;
    });

    _progressController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || !gameActive) return; // Guard against timer ending during delay
      
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showFeedback = false;
        });
      } else {
        _endGame();
      }
    });
  }

  Future<void> _endGame() async {
    if (!gameActive) return; // Prevent multiple calls

    setState(() {
      gameActive = false;
      _challengeState = _ChallengeState.completed;
    });
    _timer?.cancel();
    
    if (score == questions.length) {
      _confettiController.play();
    }
    
    await _saveCompletion();
    Future.delayed(const Duration(milliseconds: 500), _showResultDialog);
  }

  Future<void> _saveCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    
    await prefs.setBool('daily_completed_$todayKey', true);
    await prefs.setInt('daily_score_$todayKey', score);
    
    // Update streak
    final lastCompletedKey = prefs.getString('daily_last_completed');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    
    int newStreak = streak;
    if (lastCompletedKey == yesterdayKey) {
      newStreak++;
    } else if (lastCompletedKey != todayKey) {
      newStreak = 1; // Reset if they missed a day
    }
    // If lastCompletedKey == todayKey, streak doesn't change
    
    await prefs.setInt('daily_streak', newStreak);
    await prefs.setString('daily_last_completed', todayKey);
    
    setState(() {
      todaysBestScore = score;
      alreadyCompletedToday = true;
      streak = newStreak; // Update local streak
    });
  }

  // --- Question Generators ---

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _generateDailyQuestions() {
    final todayKey = _getTodayKey();
    final seed = todayKey.hashCode;
    final random = Random(seed);
    final totalQuestions = 5;

    questions = [];
    
    // Use sets to ensure no duplicate questions are picked
    final Set<int> triviaIndices = {};
    final Set<int> emojiIndices = {};
    
    final questionTypes = <QuestionType>[
      QuestionType.math,
      QuestionType.trivia,
      QuestionType.emoji,
      QuestionType.math, // Example mix
      QuestionType.trivia,
    ]..shuffle(random);


    for (int i = 0; i < totalQuestions; i++) {
      switch (questionTypes[i]) {
        case QuestionType.math:
          questions.add(_generateMathQuestion(random));
          break;
        case QuestionType.trivia:
          // Pick a unique trivia question
          int index;
          do {
            index = random.nextInt(_triviaPool.length);
          } while (triviaIndices.contains(index));
          triviaIndices.add(index);
          questions.add(_generateTriviaQuestion(random, index));
          break;
        case QuestionType.emoji:
          // Pick a unique emoji question
          int index;
          do {
            index = random.nextInt(_emojiPool.length);
          } while (emojiIndices.contains(index));
          emojiIndices.add(index);
          questions.add(_generateEmojiQuestion(random, index));
          break;
      }
    }
  }

  _Question _generateMathQuestion(Random random) {
    final operators = ['+', '-', '*'];
    final op = operators[random.nextInt(operators.length)];
    
    int a, b;
    late int answer;

    if (op == '*') {
      // Use smaller numbers for multiplication
      a = random.nextInt(12) + 2; // 2-13
      b = random.nextInt(12) + 2; // 2-13
      answer = a * b;
    } else {
      a = random.nextInt(50) + 1;
      b = random.nextInt(50) + 1;
      if (op == '+') {
        answer = a + b;
      } else {
        // Ensure non-negative answers for simplicity
        if (a < b) {
          final temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
      }
    }

    final options = <int>{answer};
    while (options.length < 4) {
      final offset = (random.nextInt(10) + 1) * (random.nextBool() ? 1 : -1);
      final opt = answer + offset;
      if (opt != answer) options.add(opt);
    }

    final optionsList = options.toList()..shuffle(random);

    return _Question(
      type: QuestionType.math,
      question: '$a $op $b = ?',
      options: optionsList.map((e) => e.toString()).toList(),
      correctIndex: optionsList.indexOf(answer),
    );
  }

  _Question _generateTriviaQuestion(Random random, int index) {
    final selected = _triviaPool[index];
    final correct = selected['a'] as String;
    final wrong = (selected['w'] as List).cast<String>();
    final allOptions = [correct, ...wrong]..shuffle(random);

    return _Question(
      type: QuestionType.trivia,
      question: selected['q'] as String,
      options: allOptions,
      correctIndex: allOptions.indexOf(correct),
    );
  }

  _Question _generateEmojiQuestion(Random random, int index) {
    final selected = _emojiPool[index];
    final correct = selected['a'] as String;
    final wrong = (selected['w'] as List).cast<String>();
    final allOptions = [correct, ...wrong]..shuffle(random);

    return _Question(
      type: QuestionType.emoji,
      question: selected['q'] as String, // Just show the emoji
      options: allOptions,
      correctIndex: allOptions.indexOf(correct),
    );
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.pink.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Main Content Area
          SafeArea(
            child: FutureBuilder(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                // Main state machine
                switch (_challengeState) {
                  case _ChallengeState.start:
                  case _ChallengeState.completed:
                    return _buildStartScreen();
                  case _ChallengeState.playing:
                    return _buildGameScreen();
                  default: // loading
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            ),
          ),
          
          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView( // Added for small screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 80,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTodayKey(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (alreadyCompletedToday) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 40),
                            const SizedBox(height: 8),
                            const Text(
                              'Completed Today!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${todaysBestScore ?? 0} / 5',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoChip('5 Questions', Icons.quiz),
                              _buildInfoChip('60 Seconds', Icons.timer),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Streak: $streak day${streak != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: alreadyCompletedToday ? null : _startChallenge,
                        child: Text(
                          alreadyCompletedToday ? 'Come Back Tomorrow' : 'Start Challenge',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    if (questions.isEmpty) return const SizedBox.shrink();
    
    final question = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;
    final prevProgress = (currentQuestionIndex) / questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with progress and time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}/${questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: timeLeft <= 10 ? Colors.red.shade300 : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${timeLeft}s',
                          style: TextStyle(
                            color: timeLeft <= 10 ? Colors.red.shade300 : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Animated Progress Bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: prevProgress, end: progress),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Question card
          Expanded(
            child: Container(
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
                  // Question type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(question.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTypeName(question.type),
                      style: TextStyle(
                        color: _getTypeColor(question.type),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Question text
                  Expanded(
                    flex: 2, // Give question text 2 parts of the space
                    child: Center(
                      child: SingleChildScrollView( // Allow text to scroll if it's too long
                        child: Text(
                          question.question,
                          style: TextStyle(
                            fontSize: question.type == QuestionType.emoji ? 64 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // --- RESPONSIVE FIX ---
                  Expanded(
                    flex: 3, // Give options 3 parts of the space
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate the perfect aspect ratio to fit 2x2 grid
                        const double crossAxisSpacing = 12;
                        const double mainAxisSpacing = 12;
                        const int crossAxisCount = 2;

                        // Get the available height and width from the LayoutBuilder
                        final double maxWidth = constraints.maxWidth;
                        final double maxHeight = constraints.maxHeight;

                        // Calculate item width
                        final double itemWidth = (maxWidth - crossAxisSpacing) / crossAxisCount;
                        
                        // Calculate item height (2 rows)
                        final double itemHeight = (maxHeight - mainAxisSpacing) / 2;

                        // Calculate aspect ratio (width / height)
                        // Handle potential divide by zero if itemHeight is 0
                        final double aspectRatio = (itemHeight <= 0) ? 1.0 : itemWidth / itemHeight;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            childAspectRatio: aspectRatio, // Use the dynamic ratio
                          ),
                          itemCount: question.options.length,
                          itemBuilder: (context, index) => _buildOptionButton(
                            question.options[index],
                            index,
                            index == question.correctIndex,
                          ),
                        );
                      },
                    ),
                  ),
                  // --- END OF FIX ---
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, bool isCorrect) {
    Color backgroundColor = Colors.purple.shade50;
    Color borderColor = Colors.purple.withOpacity(0.3);
    Color textColor = Colors.purple.shade700;
    
    if (showFeedback) {
      if (isCorrect) {
        // Show the correct answer
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (selectedAnswer == option) {
        // Show the user's wrong selection
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      } else {
        // Fade out other wrong options
        backgroundColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade400;
        textColor = Colors.grey.shade600;
      }
    }

    return GestureDetector(
      onTap: () => _answerQuestion(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            if (!showFeedback)
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // Use FittedBox to ensure text never overflows the button
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18, // Start with a good base size
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog() {
    final isPerfect = score == questions.length;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isPerfect
                  ? [Colors.amber.shade300, Colors.orange.shade600]
                  : [Colors.blue.shade300, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPerfect ? Icons.emoji_events : Icons.star,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                isPerfect ? 'Perfect!' : 'Challenge Complete!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score: $score / ${questions.length}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Streak: $streak day${streak != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  // --- Helper Methods ---

  Color _getTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.math:
        return Colors.blue;
      case QuestionType.trivia:
        return Colors.purple;
      case QuestionType.emoji:
        return Colors.orange;
    }
  }

  String _getTypeName(QuestionType type) {
    switch (type) {
      case QuestionType.math:
        return 'Math';
      case QuestionType.trivia:
        return 'Trivia';
      case QuestionType.emoji:
        return 'Emoji';
    }
  }
}