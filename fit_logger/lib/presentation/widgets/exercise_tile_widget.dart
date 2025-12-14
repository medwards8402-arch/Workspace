import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/app_constants.dart';

/// Widget for displaying an exercise in grid or list view
class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isGridView;
  final VoidCallback onTap;

  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.isGridView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: isGridView ? _buildGridItem(context) : _buildListItem(context),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
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
          const SizedBox(height: 12),
          
          // Exercise name
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              exercise.category.displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getCategoryColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Muscle groups
          Text(
            exercise.muscleGroups.take(2).join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          exercise.icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(context).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exercise.category.displayName,
                  style: TextStyle(
                    color: _getCategoryColor(context),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.muscleGroups.join(', '),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
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
