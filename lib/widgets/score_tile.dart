import 'package:flutter/material.dart';

class ScoreTile extends StatelessWidget {
  final String label;
  final int score;
  const ScoreTile({required this.label, required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(score.toString()),
    );
  }
}
