import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../data/repositories/island_repository.dart';
import '../models/island.dart';

class WorldScreen extends StatefulWidget {
  final int worldId;

  const WorldScreen({super.key, required this.worldId});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final IslandRepository _islandRepository = IslandRepository();
  late Future<List<Island>> _islandsFuture;

  @override
  void initState() {
    super.initState();
    _loadIslands();
  }

  void _loadIslands() {
    final authState = context.read<AuthBloc>().state;
    String? token;
    if (authState is AuthAuthenticated) {
      token = authState.token;
    }

    _islandsFuture = _islandRepository.getWorldIslands(widget.worldId, token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: CircularProgressIndicator());
          }

          final worldNames = {
            1: 'World 1 - Ages 6-7',
            2: 'World 2 - Ages 7-8',
            3: 'World 3 - Ages 8-9',
            4: 'World 4 - Ages 9-10',
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
                colors: [worldColors[widget.worldId]!.withOpacity(0.3), worldColors[widget.worldId]!.withOpacity(0.7)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, worldNames[widget.worldId]!, worldColors[widget.worldId]!),

                  // Islands grid
                  Expanded(
                    child: FutureBuilder<List<Island>>(
                      future: _islandsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading islands',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final islands = snapshot.data ?? [];

                        if (islands.isEmpty) {
                          return Center(
                            child: Text(
                              'No islands available',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: islands.length,
                          itemBuilder: (context, index) {
                            final island = islands[index];
                            return _buildIslandCard(
                              context,
                              island: island,
                              color: worldColors[widget.worldId]!,
                            );
                          },
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/world-map'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              worldName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildIslandCard(
    BuildContext context, {
    required Island island,
    required Color color,
  }) {
    final isUnlocked = island.isUnlocked ?? true;
    final topicCount = island.topics?.length ?? 0;

    // Category icons
    final categoryIcons = {
      'physics': Icons.science,
      'chemistry': Icons.biotech,
      'math': Icons.calculate,
      'nature': Icons.nature,
    };

    return GestureDetector(
      onTap: isUnlocked ? () => _openIsland(context, island) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? color : Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Locked overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Island content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Category icon
                  Icon(
                    categoryIcons[island.topicCategory] ?? Icons.explore,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  // Island name
                  Text(
                    island.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    island.description ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Topic count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.topic, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$topicCount topics',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openIsland(BuildContext context, Island island) {
    // Navigate to topic list screen for this island
    context.push('/topics/${island.id}');
  }
}