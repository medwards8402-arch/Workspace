import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/exercise_log.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';
import 'exercise_log_comparison_widget.dart';

/// Detailed view of a workout log
class WorkoutLogDetail extends StatelessWidget {
  final WorkoutLog log;

  const WorkoutLogDetail({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.sessionName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(log.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (log.totalDuration != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Duration: ${_formatDuration(log.totalDuration!)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                    if (log.notes != null && log.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, size: 20, color: Colors.amber[900]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log.notes!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.amber[900],
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Exercise logs
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: log.exerciseLogs.length,
                  itemBuilder: (context, index) {
                    final exerciseLog = log.exerciseLogs[index];
                    final exercise = workoutProvider._workoutService._repository.getExercise(exerciseLog.exerciseId);
                    return _buildExerciseLogCard(context, exerciseLog, exercise);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseLogCard(BuildContext context, ExerciseLog exerciseLog, Exercise? exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showComparison(context, exerciseLog),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name and icon
              Row(
                children: [
                  if (exercise != null)
                    Icon(exercise.icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exerciseLog.exerciseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _getDifficultyChip(context, exerciseLog.difficulty),
                ],
              ),
              const SizedBox(height: 12),
              
              // Performance details
              _buildPerformanceDetails(context, exerciseLog),
              
              // Notes
              if (exerciseLog.notes != null && exerciseLog.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exerciseLog.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                ),
              ],
              
              // Comparison hint
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to compare with previous workouts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
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

  Widget _buildPerformanceDetails(BuildContext context, ExerciseLog log) {
    final settings = context.watch<SettingsProvider>();
    
    switch (log) {
      case RepsOnlyLog():
        return _buildRepsOnlyDetails(context, log);
      case RepsWeightLog():
        return _buildRepsWeightDetails(context, log, settings);
      case TimeDistanceLog():
        return _buildTimeDistanceDetails(context, log, settings);
      case IntervalsLog():
        return _buildIntervalsDetails(context, log, settings);
    }
  }

  Widget _buildRepsOnlyDetails(BuildContext context, RepsOnlyLog log) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: log.repsPerSet.asMap().entries.map((entry) {
        return Chip(
          label: Text('Set ${entry.key + 1}: ${entry.value} reps'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildRepsWeightDetails(BuildContext context, RepsWeightLog log, SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: log.repsPerSet.asMap().entries.map((entry) {
        final index = entry.key;
        final reps = entry.value;
        final weight = log.weightsPerSet[index];
        final displayWeight = settings.convertWeightFromKg(weight);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                'Set ${index + 1}:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('$reps reps'),
                visualDensity: VisualDensity.compact,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(width: 4),
              Chip(
                label: Text('${displayWeight.toStringAsFixed(1)} ${settings.weightUnitLabel}'),
                visualDensity: VisualDensity.compact,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeDistanceDetails(BuildContext context, TimeDistanceLog log, SettingsProvider settings) {
    final displayDistance = settings.convertDistanceFromKm(log.distance);
    final pace = log.pace;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.timer, size: 18),
              label: Text(_formatDuration(log.duration)),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            Chip(
              avatar: const Icon(Icons.straighten, size: 18),
              label: Text('${displayDistance.toStringAsFixed(2)} ${settings.distanceUnitLabel}'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            if (pace != null)
              Chip(
                avatar: const Icon(Icons.speed, size: 18),
                label: Text('${pace.toStringAsFixed(2)} min/${settings.distanceUnitLabel}'),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntervalsDetails(BuildContext context, IntervalsLog log, SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${log.intervalCount} intervals • Total: ${_formatDuration(log.totalDuration)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        ...List.generate(log.intervalCount, (index) {
          final runDuration = log.runDurations[index];
          final walkDuration = log.walkDurations[index];
          final speed = settings.convertDistanceFromKm(log.speeds[index]);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  'Interval ${index + 1}:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Run ${_formatDuration(runDuration)}'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.green[100],
                ),
                const SizedBox(width: 4),
                Chip(
                  label: Text('Walk ${_formatDuration(walkDuration)}'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.blue[100],
                ),
                const SizedBox(width: 4),
                Chip(
                  label: Text('${speed.toStringAsFixed(1)} ${settings.speedUnitLabel}'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.orange[100],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _getDifficultyChip(BuildContext context, Difficulty difficulty) {
    IconData icon;
    Color color;
    
    switch (difficulty) {
      case Difficulty.easy:
        icon = Icons.sentiment_satisfied;
        color = Colors.green;
        break;
      case Difficulty.medium:
        icon = Icons.sentiment_neutral;
        color = Colors.orange;
        break;
      case Difficulty.hard:
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
    }
    
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        difficulty.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.1),
    );
  }

  void _showComparison(BuildContext context, ExerciseLog currentLog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExerciseLogComparison(
        sessionId: log.sessionId,
        exerciseId: currentLog.exerciseId,
        currentLog: currentLog,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
