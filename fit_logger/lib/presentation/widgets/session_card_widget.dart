import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/workout_session.dart';
import '../../core/constants/app_constants.dart';
import '../providers/workout_provider.dart';
import '../screens/session_form_screen.dart';
import '../screens/workout_logging_screen.dart';

/// Card widget displaying session information with completion checkbox
class SessionCard extends StatelessWidget {
  final WorkoutSession session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final exercises = session.exerciseIds
        .map((id) => workoutProvider.workoutService.repository.getExercise(id))
        .where((e) => e != null)
        .toList();

    return Card(
      child: InkWell(
        onTap: () => _navigateToEdit(context),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Completion checkbox
                  Checkbox(
                    value: session.completedThisWeek,
                    onChanged: (value) {
                      if (value == true) {
                        _navigateToLogging(context);
                      } else {
                        // Uncheck: Allow user to redo workout
                        workoutProvider.uncheckSessionCompletion(session.id);
                      }
                    },
                  ),
                  // Session name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: session.completedThisWeek
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                        ),
                        if (session.completedThisWeek &&
                            session.lastCompletedDate != null)
                          Text(
                            'Completed ${_formatRelativeDate(session.lastCompletedDate!)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    onPressed: () => _navigateToEdit(context),
                    tooltip: 'Edit Session',
                  ),
                ],
              ),

              // Exercise chips
              if (exercises.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: exercises.map((exercise) {
                    return Chip(
                      avatar: Icon(
                        exercise!.icon,
                        size: 16,
                      ),
                      label: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],

              // Exercise count
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${exercises.length} ${exercises.length == 1 ? 'exercise' : 'exercises'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionFormScreen(session: session),
      ),
    );
  }

  void _navigateToLogging(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutLoggingScreen(session: session),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${date.month}/${date.day}';
    }
  }
}
