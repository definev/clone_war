import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:clone_war/02_bubble_sheet/bubble_sheet.dart';
import 'package:flutter/material.dart';

const challengeData = [
  ChallengeData(
    '1',
    'Grid challenge',
    'Grid challenge is a two-dimensional grid layout challenge',
  ),
  ChallengeData(
    '2',
    'Bubble challenge',
    'Bubble challenge modal effect',
  ),
];

class ChallengeData {
  const ChallengeData(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;
}

class ChallengePage extends StatelessWidget {
  const ChallengePage(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    switch (id) {
      case '1':
        return const GridLayoutChallenge();
      case '2':
        return const BubbleSheetChallenge();
      default:
        return const Center(child: Text('Unknown challenge'));
    }
  }
}
