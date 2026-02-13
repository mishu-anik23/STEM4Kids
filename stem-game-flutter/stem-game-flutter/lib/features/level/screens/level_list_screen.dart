import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/island_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../world/models/level.dart';

class LevelListScreen extends StatefulWidget {
  final String topicId;
  final int worldId;

  const LevelListScreen({super.key, required this.topicId, required this.worldId});

  @override
  State<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  final IslandRepository _repository = IslandRepository();
  late Future<Map<String, dynamic>> _levelsFuture;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() {
    final authState = context.read<AuthBloc>().state;
    String? token;
    if (authState is AuthAuthenticated) {
      token = authState.token;
    }

    _levelsFuture = _repository.getTopicLevels(widget.topicId, token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Topic Locked',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final topic = data['topic'] as Map<String, dynamic>;
          final levels = (data['levels'] as List)
              .map((l) => Level.fromJson(l as Map<String, dynamic>))
              .toList();

          return Column(
            children: [
              // Topic header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['name'] as String,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic['description'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.games, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${levels.length} Levels',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          topic['difficultyLevel'] as String? ?? 'Beginner',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Levels grid
              Expanded(
                child: levels.isEmpty
                    ? const Center(
                        child: Text('No levels available'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          return _buildLevelCard(context, level);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Level level) {
    final isUnlocked = level.isUnlocked ?? true;
    final isCompleted = level.userProgress?.completed ?? false;
    final stars = level.userProgress?.stars ?? 0;

    return Card(
      elevation: isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isUnlocked ? () => _playLevel(context, level) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isUnlocked ? null : Colors.grey[300],
            gradient: isCompleted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number or lock icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (isCompleted ? Colors.green : Theme.of(context).primaryColor)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '${level.levelNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.lock, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 12),

              // Level name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  level.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black87 : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Stars or locked indicator
              if (isUnlocked && isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    level.maxStars,
                    (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                )
              else if (!isUnlocked)
                Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const Icon(
                  Icons.play_circle_outline,
                  color: Colors.blue,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _playLevel(BuildContext context, Level level) {
    // Navigate to level gameplay screen using existing GameScreen route
    context.push('/game/${widget.worldId}/${level.id}');
  }
}
