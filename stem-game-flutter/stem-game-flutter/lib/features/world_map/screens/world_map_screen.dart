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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[200]!, Colors.green[200]!],
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
                          icon: Icons.calculate,
                          color: Colors.orange,
                          isUnlocked: true,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 2,
                          title: 'Physics Planet',
                          icon: Icons.science,
                          color: Colors.blue,
                          isUnlocked: user.currentWorld >= 2,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 3,
                          title: 'Chemistry Kingdom',
                          icon: Icons.science_outlined,
                          color: Colors.purple,
                          isUnlocked: user.currentWorld >= 3,
                        ),
                        _buildWorldCard(
                          context,
                          worldId: 4,
                          title: 'Nature Realm',
                          icon: Icons.eco,
                          color: Colors.green,
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
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Grade ${user.grade}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),

          // Stats
          Row(
            children: [
              _buildStatChip(Icons.star, user.totalStars.toString(), Colors.amber),
              SizedBox(width: 8),
              _buildStatChip(Icons.monetization_on, user.coins.toString(), Colors.yellow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
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
          Icon(icon, size: 20, color: color),
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
    required IconData icon,
    required Color color,
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
            // Background
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: isUnlocked ? color : Colors.grey,
                child: Center(
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
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