import 'package:clone_war/01_grid_layout/grid_zoom.dart';
import 'package:clone_war/02_bubble_sheet/bubble_sheet_view.dart';
import 'package:clone_war/03_riveo_page_curl/riveo_page_curl_view.dart';
import 'package:clone_war/04_shader_art_coding/shader_art_coding_view.dart';
import 'package:clone_war/05_spring_card/spring_card_view.dart';
import 'package:clone_war/06_custom_render_object/custom_render_object_view.dart';
import 'package:clone_war/home_screen.dart';
import 'package:clone_war/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/challenge/:id',
        builder: (context, state) => switch (state.pathParameters['id']) {
          '1' => const GridLayoutChallenge(),
          '2' => const BubbleSheetView(),
          '3' => const RiveoPageCurlView() //
              .useMaterial3
              .setFontFamily('Unique'),
          '4' => const ShaderArtCodingView(),
          '5' => const SpringCardView(),
          '6' => const CustomRenderObjectView(),
          _ => const Center(child: Text('Unknown challenge')),
        },
      ),
    ],
  );
}
