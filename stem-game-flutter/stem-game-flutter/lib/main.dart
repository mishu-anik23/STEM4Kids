import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_router.dart';
import 'core/services/game_sound_service.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/progress/bloc/progress_bloc.dart';
import 'features/leaderboard/bloc/leaderboard_bloc.dart';
import 'features/game/bloc/game_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Setup dependency injection
  await setupServiceLocator();

  // Initialize game sound effects
  await GameSoundService.init();

  runApp(const StemLearningGame());
}

class StemLearningGame extends StatelessWidget {
  const StemLearningGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<ProgressBloc>()),
        BlocProvider(create: (context) => getIt<LeaderboardBloc>()),
        BlocProvider(create: (context) => getIt<GameBloc>()),
      ],
      child: MaterialApp.router(
        title: 'STEM Learning Game',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
