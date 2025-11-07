// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _CardModel {
  final int id;
  final String content;
  bool revealed = false;
  bool matched = false;

  _CardModel({
    required this.id,
    required this.content,
  });
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  int gridSize = 4; // 4x4 or 6x6
  late List<_CardModel> cards;
  _CardModel? firstRevealed;
  _CardModel? secondRevealed;
  bool busy = false;
  int moves = 0;
  late Stopwatch _stopwatch;
  Timer? _timer;
  late ConfettiController _confettiController;
  int? bestTimeSeconds;
  int? bestMoves;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _newGame();
    _loadBest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopwatch.stop();
  }

  List<String> _emojiPoolForGrid(int size) {
    // Large pool of unique emojis to support up to 6x6 (18 pairs)
    const pool = [
      '🍎','🍌','🍇','🍓','🍒','🍍','🥝','🍉',
      '🍋','🍑','🍐','🥭','🫐','🥥','🌽','🥕','🥔','🍆','🌶️','🍄','🥦','🧅','🧄','🍞',
      '🍪','🍰','🍫','🍭','🍩','🧁','🍔','🍕','🌮','🍣','🍱','🍙'
    ];
    final neededPairs = (size * size) ~/ 2;
    return pool.take(neededPairs).toList();
  }

  void _newGame() {
    final emoji = _emojiPoolForGrid(gridSize);
    final list = <_CardModel>[];
    int id = 0;
    for (var e in emoji) {
      list.add(_CardModel(id: id++, content: e));
      list.add(_CardModel(id: id++, content: e));
    }

    list.shuffle(Random());
    setState(() {
      cards = list;
      firstRevealed = null;
      secondRevealed = null;
      busy = false;
      moves = 0;
      _timer?.cancel();
      _stopwatch.reset();
    });
  }

  void _onTapCard(int index) async {
    if (busy) return;
    final card = cards[index];
    if (card.matched || card.revealed) return;

    setState(() => card.revealed = true);

    // start timer on first action
    if (!_stopwatch.isRunning) _startTimer();

    if (firstRevealed == null) {
      firstRevealed = card;
      return;
    }

    secondRevealed = card;
    moves++;
    busy = true;

    await Future.delayed(const Duration(milliseconds: 700));

    if (firstRevealed!.content == secondRevealed!.content) {
      setState(() {
        firstRevealed!.matched = true;
        secondRevealed!.matched = true;
      });
    } else {
      setState(() {
        firstRevealed!.revealed = false;
        secondRevealed!.revealed = false;
      });
    }

    firstRevealed = null;
    secondRevealed = null;
    busy = false;

    // check win
    if (cards.every((c) => c.matched)) {
      _stopTimer();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final seconds = _stopwatch.elapsed.inSeconds;
    _confettiController.play();
    _maybeSaveBest(seconds, moves);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('You Win!'),
        content: Text('Time: ${seconds}s\nMoves: $moves'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestTimeSeconds = prefs.getInt('memory_best_time_$gridSize');
      bestMoves = prefs.getInt('memory_best_moves_$gridSize');
    });
  }

  Future<void> _maybeSaveBest(int seconds, int moves) async {
    final prefs = await SharedPreferences.getInstance();
    var updated = false;
    if (bestTimeSeconds == null || seconds < bestTimeSeconds!) {
      await prefs.setInt('memory_best_time_$gridSize', seconds);
      bestTimeSeconds = seconds;
      updated = true;
    }
    if (bestMoves == null || moves < bestMoves!) {
      await prefs.setInt('memory_best_moves_$gridSize', moves);
      bestMoves = moves;
      updated = true;
    }
    if (updated) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = gridSize;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate available space for grid
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final topPadding = 16.0;
    final controlsHeight = 60.0; // Approximate height of top controls
    final spacing = 12.0;
    
    final availableHeight = screenHeight - appBarHeight - statusBarHeight - topPadding * 2 - controlsHeight - spacing;
    final availableWidth = screenWidth - 32.0; // Side padding
    
    // Calculate card size to fit the screen
    final gridSpacing = 8.0;
    final maxCardSize = min(
      (availableWidth - (gridSpacing * (crossAxisCount - 1))) / crossAxisCount,
      (availableHeight - (gridSpacing * (crossAxisCount - 1))) / crossAxisCount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Moves: $moves', style: const TextStyle(fontSize: 14)),
                          if (bestMoves != null) Text('Best: $bestMoves', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Time: ${_stopwatch.elapsed.inSeconds}s', style: const TextStyle(fontSize: 14)),
                          if (bestTimeSeconds != null) Text('Best: ${bestTimeSeconds}s', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: gridSize,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('4x4')),
                        DropdownMenuItem(value: 6, child: Text('6x6')),
                      ],
                      onChanged: (v) {
                        if (v == null || v == gridSize) return;
                        setState(() => gridSize = v);
                        _newGame();
                        _loadBest();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _newGame,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Restart',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: maxCardSize * crossAxisCount + gridSpacing * (crossAxisCount - 1),
                    height: maxCardSize * crossAxisCount + gridSpacing * (crossAxisCount - 1),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: 1,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return GestureDetector(
                          onTap: () => _onTapCard(index),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: card.revealed || card.matched
                                ? Container(
                                    key: ValueKey('revealed-${card.id}'),
                                    decoration: BoxDecoration(
                                      color: card.matched ? Colors.green.shade200 : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(card.content, style: const TextStyle(fontSize: 32)),
                                  )
                                : Container(
                                    key: ValueKey('hidden-${card.id}'),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.help_outline, size: 32, color: Colors.white),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
            ),
          ),
        ],
      ),
    );
  }
}