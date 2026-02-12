# Flutter Implementation Samples

## Essential Flutter Files to Create

### 1. API Service (lib/data/services/api_service.dart)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}
```

### 2. User Model (lib/data/models/user.dart)

```dart
class User {
  final String id;
  final String username;
  final int age;
  final int grade;
  final int coins;
  final int totalStars;
  final int currentWorld;
  final int currentLevel;
  final String avatarUrl;
  final bool parentVerified;
  final int loginStreak;

  User({
    required this.id,
    required this.username,
    required this.age,
    required this.grade,
    required this.coins,
    required this.totalStars,
    required this.currentWorld,
    required this.currentLevel,
    required this.avatarUrl,
    required this.parentVerified,
    this.loginStreak = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      age: json['age'],
      grade: json['grade'],
      coins: json['coins'],
      totalStars: json['totalStars'],
      currentWorld: json['currentWorld'],
      currentLevel: json['currentLevel'],
      avatarUrl: json['avatarUrl'],
      parentVerified: json['parentVerified'],
      loginStreak: json['loginStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'age': age,
      'grade': grade,
      'coins': coins,
      'totalStars': totalStars,
      'currentWorld': currentWorld,
      'currentLevel': currentLevel,
      'avatarUrl': avatarUrl,
      'parentVerified': parentVerified,
      'loginStreak': loginStreak,
    };
  }
}
```

### 3. Auth BLoC (lib/features/auth/bloc/auth_bloc.dart)

```dart
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
  final int age;
  final int grade;

  RegisterEvent({
    required this.username,
    required this.password,
    required this.parentEmail,
    required this.age,
    required this.grade,
  });

  @override
  List<Object?> get props => [username, password, parentEmail, age, grade];
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
```

### 4. Login Screen (lib/features/auth/screens/login_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          _usernameController.text,
          _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/world-map');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[400]!, Colors.purple[600]!],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'STEM Learning Game',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is AuthLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Register button
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          'Don\'t have an account? Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 5. World Map Screen (lib/features/world_map/screens/world_map_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/world_map.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _buildTopBar(context, user),
                  
                  // Worlds grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(24),
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      children: [
                        _buildWorldCard(
                          context,
                          worldId: 1,
                          title: 'Math Island',
                          imagePath: 'assets/images/worlds/world_1_math.png',
                          isUnlocked: true,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 2,
                          title: 'Physics Planet',
                          imagePath: 'assets/images/worlds/world_2_physics.png',
                          isUnlocked: user.currentWorld >= 2,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 3,
                          title: 'Chemistry Kingdom',
                          imagePath: 'assets/images/worlds/world_3_chemistry.png',
                          isUnlocked: user.currentWorld >= 3,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 4,
                          title: 'Nature Realm',
                          imagePath: 'assets/images/worlds/world_4_nature.png',
                          isUnlocked: user.currentWorld >= 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, user) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(user.avatarUrl),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Grade ${user.grade}'),
                ],
              ),
            ],
          ),
          
          // Stats
          Row(
            children: [
              _buildStatChip(Icons.star, user.totalStars.toString()),
              SizedBox(width: 8),
              _buildStatChip(Icons.monetization_on, user.coins.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(
    BuildContext context, {
    required int worldId,
    required String title,
    required String imagePath,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => context.push('/world/$worldId')
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isUnlocked ? null : Colors.black54,
                colorBlendMode: isUnlocked ? null : BlendMode.darken,
              ),
            ),
            
            // Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Lock icon if locked
            if (!isUnlocked)
              Center(
                child: Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 6. Service Locator (lib/core/di/service_locator.dart)

```dart
import 'package:get_it/get_it.dart';
import '../../data/services/api_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/progress/bloc/progress_bloc.dart';
import '../../features/leaderboard/bloc/leaderboard_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<ApiService>()));
  getIt.registerFactory<ProgressBloc>(() => ProgressBloc(getIt<ApiService>()));
  getIt.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(getIt<ApiService>()));
}
```

### 7. App Router (lib/core/routes/app_router.dart)

```dart
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/world_map/screens/world_map_screen.dart';

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
      // Add more routes as needed
    ],
  );
}
```

---

## Next Steps

1. Create these files in your Flutter project
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
4. Connect to your backend API
5. Test login and registration

The above code provides a solid foundation. You'll need to:
- Add error handling
- Implement remaining screens (register, levels, leaderboard)
- Add Flame game components
- Create level implementations
- Add animations and sound
- Implement local storage with Hive

Refer to the DEVELOPMENT_GUIDE.md for the complete workflow!
```
