import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:clone_war/02_bubble_sheet/bubble_sheet_view.dart';
import 'package:clone_war/03_riveo_page_curl/riveo_page_curl_view.dart';
import 'package:clone_war/04_shader_art_coding/shader_art_coding_view.dart';
import 'package:clone_war/utils/extensions.dart';
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
  ChallengeData(
    '3',
    'Riveo page curl challenge',
    'An animation simulating the turning of a physical page, adding depth and interactivity to digital content.',
  ),
  ChallengeData(
    '4',
    'Shader art coding tutorial',
    'Shader art coding tutorial is a tutorial on how to create a shader art coding effect.',
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
        return const BubbleSheetView();
      case '3':
        return const RiveoPageCurlView() //
            .useMaterial3
            .setFontFamily('Unique');
      case '4':
        return const ShaderArtCodingView();
      default:
        return const Center(child: Text('Unknown challenge'));
    }
  }
}
