import 'package:clone_war/grid_zoom.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CloneWar());
}

class CloneWar extends StatelessWidget {
  const CloneWar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clone War',
      theme: FlexColorScheme.dark(
        scheme: FlexScheme.aquaBlue,
      ).toTheme,
      home: const GridLayoutChallenge(),
    );
  }
}
