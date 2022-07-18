import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:clone_war/utils/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CloneWar());
}

class CloneWar extends StatelessWidget {
  const CloneWar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clone War',
      theme: FlexColorScheme.dark(
        scheme: FlexScheme.aquaBlue,
        useMaterial3: true,
      ).toTheme,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
    );
  }
}
