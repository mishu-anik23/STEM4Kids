import 'package:get_it/get_it.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/level_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/progress/bloc/progress_bloc.dart';
import '../../features/leaderboard/bloc/leaderboard_bloc.dart';
import '../../features/game/bloc/game_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<LevelRepository>(() => LevelRepository());

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<ApiService>()));
  getIt.registerFactory<ProgressBloc>(() => ProgressBloc(getIt<ApiService>()));
  getIt.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(getIt<ApiService>()));
  getIt.registerFactory<GameBloc>(() => GameBloc(getIt<LevelRepository>()));
}