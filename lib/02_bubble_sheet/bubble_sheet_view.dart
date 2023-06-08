import 'package:clone_war/02_bubble_sheet/bubble_sheet.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class BubbleSheetView extends StatelessWidget {
  const BubbleSheetView({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const _ExamplePage(),
          ),
          backgroundColor: FlexColorScheme.light(
            scheme: FlexScheme.aquaBlue,
            useMaterial3: true,
          ).toTheme.primaryColor,
          child: const _ExamplePage(),
        ),
      ),
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage({
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
              children: const [
                Card(child: FlutterLogo()),
                Card(child: FlutterLogo()),
                Card(child: FlutterLogo()),
                Card(child: FlutterLogo()),
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
