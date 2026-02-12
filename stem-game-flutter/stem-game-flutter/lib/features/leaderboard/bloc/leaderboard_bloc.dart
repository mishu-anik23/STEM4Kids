import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/services/api_service.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLeaderboardEvent extends LeaderboardEvent {}

// States
abstract class LeaderboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<dynamic> leaderboard;

  LeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ApiService apiService;

  LeaderboardBloc(this.apiService) : super(LeaderboardInitial()) {
    on<LoadLeaderboardEvent>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoading());

    try {
      final response = await apiService.get('/leaderboard');
      final leaderboard = response['data'] as List<dynamic>;

      emit(LeaderboardLoaded(leaderboard));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}