import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user.dart';
import '../../../data/services/api_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String parentEmail;
  final int? age;
  final int? grade;
  final String userType;

  RegisterEvent({
    required this.username,
    required this.password,
    required this.parentEmail,
    this.age,
    this.grade,
    this.userType = 'student',
  });

  @override
  List<Object?> get props => [username, password, parentEmail, age, grade, userType];
}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;

  AuthAuthenticated(this.user, this.token);

  @override
  List<Object?> get props => [user, token];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc(this.apiService) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await apiService.post('/auth/login', {
        'username': event.username,
        'password': event.password,
      });

      final user = User.fromJson(response['data']['user']);
      final token = response['data']['token'];

      apiService.setToken(token);

      emit(AuthAuthenticated(user, token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await apiService.post('/auth/register', {
        'username': event.username,
        'password': event.password,
        'parentEmail': event.parentEmail,
        'age': event.age,
        'grade': event.grade,
        'userType': event.userType,
      });

      final user = User.fromJson(response['data']['user']);
      final token = response['data']['token'];

      apiService.setToken(token);

      emit(AuthAuthenticated(user, token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await apiService.post('/auth/logout', {});
    apiService.setToken('');
    emit(AuthInitial());
  }
}