import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:clone_war/02_bubble_sheet/bubble_sheet.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
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
        return SafeArea(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: BubbleSheet(
              bottomSheet: Theme(
                data: FlexColorScheme.light(
                  scheme: FlexScheme.aquaBlue,
                  useMaterial3: true,
                ).toTheme,
                child: const ExamplePage(),
              ),
              backgroundColor: FlexColorScheme.light(
                scheme: FlexScheme.aquaBlue,
                useMaterial3: true,
              ).toTheme.primaryColor,
              child: const ExamplePage(),
            ),
          ),
        );
      default:
        return const Center(child: Text('Unknown challenge'));
    }
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        leading: const SizedBox(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              children: [
                const Card(child: FlutterLogo()),
                const Card(child: FlutterLogo()),
                const Card(child: FlutterLogo()),
                const Card(child: FlutterLogo()),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.leaderboard),
                  title: const Text('Leaderboard'),
                  subtitle: const Text('View the leaderboard'),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  subtitle: const Text('View the settings'),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('View the about page'),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  subtitle: const Text('Logout of the application'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
