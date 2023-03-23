import 'package:clone_war/home_screen.dart';
import 'package:clone_war/utils/challenge_data.dart';
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
        builder: (context, state) => ChallengePage(state.params['id']!),
      ),
    ],
  );
}
