import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/island_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../world/models/island.dart';
import '../../world/models/topic.dart';

class TopicListScreen extends StatefulWidget {
  final String islandId;

  const TopicListScreen({super.key, required this.islandId});

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  final IslandRepository _repository = IslandRepository();
  late Future<Map<String, dynamic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  void _loadTopics() {
    final authState = context.read<AuthBloc>().state;
    String? token;
    if (authState is AuthAuthenticated) {
      token = authState.token;
    }

    _topicsFuture = _repository.getIslandWithTopics(widget.islandId, token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading topics',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadTopics()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final island = data['island'] as Map<String, dynamic>;
          final topics = (data['topics'] as List)
              .map((t) => Topic.fromJson(t as Map<String, dynamic>))
              .toList();

          return Column(
            children: [
              // Island header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(island['topicCategory']),
                      _getCategoryColor(island['topicCategory']).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      island['name'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      island['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${topics.length} Topics',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Topics list
              Expanded(
                child: topics.isEmpty
                    ? const Center(
                        child: Text('No topics available'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return _buildTopicCard(context, topic, index + 1);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Topic topic, int number) {
    final isUnlocked = topic.isUnlocked ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isUnlocked ? () => _openTopic(context, topic) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isUnlocked ? null : Colors.grey[300],
          ),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.lock, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Topic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: isUnlocked ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.levelCount} Levels',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 16,
                          color: isUnlocked ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          topic.difficultyLevel ?? 'Beginner',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnlocked ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: isUnlocked ? Colors.grey[400] : Colors.grey[300],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTopic(BuildContext context, Topic topic) {
    // Navigate to level list screen
    context.push('/levels/${topic.id}');
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'physics':
        return Colors.orange;
      case 'chemistry':
        return Colors.blue;
      case 'math':
        return Colors.purple;
      case 'nature':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
