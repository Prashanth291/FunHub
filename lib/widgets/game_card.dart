import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const GameCard({required this.title, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
