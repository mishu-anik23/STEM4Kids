import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/world_map/screens/world_map_screen.dart';
import '../../features/world/screens/world_screen.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/game/screens/level_complete_screen.dart';
import '../../features/game/bloc/game_state.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/world-map',
        builder: (context, state) => const WorldMapScreen(),
      ),
      GoRoute(
        path: '/world/:id',
        builder: (context, state) {
          final worldId = int.parse(state.pathParameters['id']!);
          return WorldScreen(worldId: worldId);
        },
      ),
      GoRoute(
        path: '/game/:worldId/:levelId',
        builder: (context, state) {
          final worldId = int.parse(state.pathParameters['worldId']!);
          final levelId = int.parse(state.pathParameters['levelId']!);
          return GameScreen(worldId: worldId, levelId: levelId);
        },
      ),
      GoRoute(
        path: '/level-complete',
        builder: (context, state) {
          final levelCompleted = state.extra as LevelCompleted;
          return LevelCompleteScreen(levelCompleted: levelCompleted);
        },
      ),
    ],
  );
}