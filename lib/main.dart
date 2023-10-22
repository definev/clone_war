import 'package:clone_war/utils/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CloneWar());
}

class CloneWar extends StatelessWidget {
  const CloneWar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clone War',
      theme: FlexColorScheme.light(
        scheme: FlexScheme.amber,
        useMaterial3: true,
      ).toTheme,
      routerConfig: AppRouter.router,
    );
  }
}
