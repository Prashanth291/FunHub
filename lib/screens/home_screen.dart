// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GameItem {
  final String title;
  final String route;
  final IconData icon;
  final Color color;
  final String? description;

  const GameItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.color,
    this.description,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Only show playable games (Leaderboard and Profile are in bottom nav)
  static const List<GameItem> _games = [
    GameItem(
      title: 'Guess the Number',
      route: '/guess',
      icon: Icons.casino,
      color: Color(0xFF6366F1),
      description: 'Test your intuition',
    ),
    GameItem(
      title: 'Trivia Quiz',
      route: '/quiz',
      icon: Icons.quiz,
      color: Color(0xFFEC4899),
      description: 'Challenge your knowledge',
    ),
    GameItem(
      title: 'Memory Match',
      route: '/memory',
      icon: Icons.memory,
      color: Color(0xFF8B5CF6),
      description: 'Match pairs & win',
    ),
    GameItem(
      title: 'Math Challenge',
      route: '/math',
      icon: Icons.calculate,
      color: Color(0xFF10B981),
      description: 'Solve in seconds',
    ),
    GameItem(
      title: 'Emoji Quiz',
      route: '/emoji',
      icon: Icons.emoji_emotions,
      color: Color(0xFFF59E0B),
      description: 'Decode the emojis',
    ),
    GameItem(
      title: 'Daily Challenge',
      route: '/daily',
      icon: Icons.star,
      color: Color(0xFFEF4444),
      description: 'New puzzle daily',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.games_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'FunHub',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 4),
                Text(
                  '1250',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a game to play',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Horizontal Games List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _games.length,
                itemBuilder: (context, index) => _HorizontalGameCard(
                  game: _games[index],
                  index: index,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalGameCard extends StatefulWidget {
  final GameItem game;
  final int index;

  const _HorizontalGameCard({
    required this.game,
    required this.index,
  });

  @override
  State<_HorizontalGameCard> createState() => _HorizontalGameCardState();
}

class _HorizontalGameCardState extends State<_HorizontalGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: () {
          Navigator.pushNamed(context, widget.game.route);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.game.color.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.game.color.withOpacity(_isPressed ? 0.15 : 0.08),
                  blurRadius: _isPressed ? 16 : 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Gradient background
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.game.color.withOpacity(0.15),
                            widget.game.color.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon/Image Section
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.game.color,
                                widget.game.color.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.game.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.game.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Text Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.game.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (widget.game.description != null)
                                Text(
                                  widget.game.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        
                        // Arrow/Play Button
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.game.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: widget.game.color,
                            size: 18,
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
      ),
    );
  }
}