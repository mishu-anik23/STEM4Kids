import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';

class WorldScreen extends StatelessWidget {
  final int worldId;

  const WorldScreen({super.key, required this.worldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final worldNames = {
            1: 'Math Island',
            2: 'Physics Planet',
            3: 'Chemistry Kingdom',
            4: 'Nature Realm',
          };

          final worldColors = {
            1: Colors.orange,
            2: Colors.blue,
            3: Colors.purple,
            4: Colors.green,
          };

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [worldColors[worldId]!.withOpacity(0.3), worldColors[worldId]!.withOpacity(0.7)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, worldNames[worldId]!, worldColors[worldId]!),

                  // Levels grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 20, // 20 levels per world
                      itemBuilder: (context, index) {
                        final levelId = index + 1;
                        final isUnlocked = _isLevelUnlocked(user, worldId, levelId);

                        return _buildLevelCard(
                          context,
                          worldId: worldId,
                          levelId: levelId,
                          isUnlocked: isUnlocked,
                          color: worldColors[worldId]!,
                        );
                      },
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

  Widget _buildHeader(BuildContext context, String worldName, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/world-map'),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              worldName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int worldId,
    required int levelId,
    required bool isUnlocked,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () => _startLevel(context, worldId, levelId) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? color : Colors.grey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            levelId.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool _isLevelUnlocked(user, int worldId, int levelId) {
    // Logic to determine if level is unlocked
    if (worldId < user.currentWorld) return true;
    if (worldId == user.currentWorld && levelId <= user.currentLevel) return true;
    return false;
  }

  void _startLevel(BuildContext context, int worldId, int levelId) {
    context.go('/game/$worldId/$levelId');
  }
}