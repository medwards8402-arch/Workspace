import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/workout_provider.dart';

/// Bottom sheet showing detailed exercise information
class ExerciseDetail extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetail({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exercise.icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(context).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          exercise.category.displayName,
                          style: TextStyle(
                            color: _getCategoryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Measurement type
            _buildInfoCard(
              context,
              'Measurement Type',
              Icons.straighten,
              [exercise.measurementType.displayName],
            ),
            const SizedBox(height: 16),

            // Muscle groups
            _buildInfoCard(
              context,
              'Primary Muscles',
              Icons.accessibility_new,
              exercise.muscleGroups,
            ),
            const SizedBox(height: 16),

            // Equipment
            if (exercise.equipment.isNotEmpty) ...[
              _buildInfoCard(
                context,
                'Equipment Needed',
                Icons.fitness_center,
                exercise.equipment,
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildInfoCard(
                context,
                'Equipment',
                Icons.fitness_center,
                ['No equipment needed'],
              ),
              const SizedBox(height: 16),
            ],

            // Recent activity
            FutureBuilder<Map<String, dynamic>>(
              future: _getExerciseStats(context),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final stats = snapshot.data!;
                final timesPerformed = stats['count'] as int;
                final lastPerformed = stats['lastDate'] as DateTime?;

                if (timesPerformed == 0) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You haven\'t performed this exercise yet',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Activity',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              'Times Performed',
                              timesPerformed.toString(),
                              Icons.repeat,
                            ),
                            if (lastPerformed != null)
                              _buildStatItem(
                                context,
                                'Last Performed',
                                _formatDate(lastPerformed),
                                Icons.calendar_today,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getExerciseStats(BuildContext context) async {
    final workoutProvider = context.read<WorkoutProvider>();
    final allLogs = await workoutProvider.workoutService.repository.getAllLogs();

    int count = 0;
    DateTime? lastDate;

    for (final log in allLogs) {
      for (final exerciseLog in log.exerciseLogs) {
        if (exerciseLog.exerciseId == exercise.id) {
          count++;
          if (lastDate == null || log.timestamp.isAfter(lastDate)) {
            lastDate = log.timestamp;
          }
        }
      }
    }

    return {
      'count': count,
      'lastDate': lastDate,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Color _getCategoryColor(BuildContext context) {
    switch (exercise.category) {
      case ExerciseCategory.bodyweight:
        return Colors.blue;
      case ExerciseCategory.barbell:
        return Colors.deepPurple;
      case ExerciseCategory.dumbbell:
        return Colors.orange;
      case ExerciseCategory.kettlebell:
        return Colors.red;
      case ExerciseCategory.medicineBall:
        return Colors.pink;
      case ExerciseCategory.band:
        return Colors.green;
      case ExerciseCategory.cardio:
        return Colors.teal;
    }
  }
}
