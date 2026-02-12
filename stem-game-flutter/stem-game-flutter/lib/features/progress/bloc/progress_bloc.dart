import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/services/api_service.dart';

// Events
abstract class ProgressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProgressEvent extends ProgressEvent {}

class SubmitLevelCompletionEvent extends ProgressEvent {
  final int worldId;
  final int levelId;
  final int score;
  final int timeSpentSeconds;
  final int hintsUsed;

  SubmitLevelCompletionEvent({
    required this.worldId,
    required this.levelId,
    required this.score,
    required this.timeSpentSeconds,
    required this.hintsUsed,
  });

  @override
  List<Object?> get props => [worldId, levelId, score, timeSpentSeconds, hintsUsed];
}

// States
abstract class ProgressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<dynamic> progress;

  ProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ProgressError extends ProgressState {
  final String message;

  ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}

class LevelCompletionSuccess extends ProgressState {
  final Map<String, dynamic> data;

  LevelCompletionSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

// BLoC
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ApiService apiService;

  ProgressBloc(this.apiService) : super(ProgressInitial()) {
    on<LoadProgressEvent>(_onLoadProgress);
    on<SubmitLevelCompletionEvent>(_onSubmitLevelCompletion);
  }

  Future<void> _onLoadProgress(LoadProgressEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());

    try {
      final response = await apiService.get('/progress');
      final progress = response['data'] as List<dynamic>;

      emit(ProgressLoaded(progress));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> _onSubmitLevelCompletion(
    SubmitLevelCompletionEvent event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      final response = await apiService.post('/progress/complete', {
        'worldId': event.worldId,
        'levelId': event.levelId,
        'score': event.score,
        'timeSpentSeconds': event.timeSpentSeconds,
        'hintsUsed': event.hintsUsed,
      });

      emit(LevelCompletionSuccess(response['data'] as Map<String, dynamic>));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}