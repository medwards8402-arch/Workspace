import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/workout_session.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/workout_provider.dart';
import '../widgets/reps_only_form_widget.dart';
import '../widgets/reps_weight_form_widget.dart';
import '../widgets/time_distance_form_widget.dart';
import '../widgets/intervals_form_widget.dart';

/// Screen for logging a workout session
class WorkoutLoggingScreen extends StatefulWidget {
  final WorkoutSession session;

  const WorkoutLoggingScreen({super.key, required this.session});

  @override
  State<WorkoutLoggingScreen> createState() => _WorkoutLoggingScreenState();
}

class _WorkoutLoggingScreenState extends State<WorkoutLoggingScreen> {
  final Map<String, ExerciseLog> _exerciseLogs = {};
  final TextEditingController _notesController = TextEditingController();
  final Uuid _uuid = const Uuid();
  DateTime? _startTime;
  bool _isSaving = false;
  String? _suggestion;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadSuggestion();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestion() async {
    final suggestion = await context.read<WorkoutProvider>().getWorkoutSuggestion(widget.session.id);
    if (mounted) {
      setState(() {
        _suggestion = suggestion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final exercises = widget.session.exerciseIds
        .map((id) => workoutProvider._workoutService._repository.getExercise(id))
        .where((e) => e != null)
        .cast<Exercise>()
        .toList();

    final completedCount = _exerciseLogs.length;
    final totalCount = exercises.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          if (_exerciseLogs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Complete Workout',
              onPressed: _isSaving ? null : _completeWorkout,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
          ),
          
          // Suggestion banner
          if (_suggestion != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _suggestion!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Progress summary
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: $completedCount / $totalCount exercises',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_startTime != null)
                  Text(
                    'Duration: ${_formatDuration(DateTime.now().difference(_startTime!))}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final isCompleted = _exerciseLogs.containsKey(exercise.id);

                return Card(
                  child: InkWell(
                    onTap: () => _logExercise(exercise),
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Row(
                        children: [
                          // Checkbox
                          Checkbox(
                            value: isCompleted,
                            onChanged: (_) => _logExercise(exercise),
                          ),
                          // Exercise info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise.category.displayName} • ${exercise.measurementType.displayName}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _exerciseLogs[exercise.id]!.getSummary(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Edit icon
                          Icon(
                            isCompleted ? Icons.edit : Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Notes section
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Workout Notes (Optional)',
                hintText: 'How did it feel? Any observations?',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ),

          // Complete button
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: FilledButton.icon(
              onPressed: _exerciseLogs.isEmpty || _isSaving ? null : _completeWorkout,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Complete Workout'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logExercise(Exercise exercise) async {
    final workoutProvider = context.read<WorkoutProvider>();
    
    // Get pre-fill data
    final prefillLog = await workoutProvider.getPrefillData(
      sessionId: widget.session.id,
      exerciseId: exercise.id,
    );

    if (!mounted) return;

    // Show appropriate form based on measurement type
    ExerciseLog? log;
    switch (exercise.measurementType) {
      case MeasurementType.repsOnly:
        log = await showDialog<ExerciseLog>(
          context: context,
          builder: (context) => RepsOnlyForm(
            exercise: exercise,
            prefillLog: prefillLog as RepsOnlyLog?,
          ),
        );
        break;
      case MeasurementType.repsWeight:
        log = await showDialog<ExerciseLog>(
          context: context,
          builder: (context) => RepsWeightForm(
            exercise: exercise,
            prefillLog: prefillLog as RepsWeightLog?,
          ),
        );
        break;
      case MeasurementType.timeDistance:
        log = await showDialog<ExerciseLog>(
          context: context,
          builder: (context) => TimeDistanceForm(
            exercise: exercise,
            prefillLog: prefillLog as TimeDistanceLog?,
          ),
        );
        break;
      case MeasurementType.intervals:
        log = await showDialog<ExerciseLog>(
          context: context,
          builder: (context) => IntervalsForm(
            exercise: exercise,
            prefillLog: prefillLog as IntervalsLog?,
          ),
        );
        break;
    }

    if (log != null) {
      setState(() {
        _exerciseLogs[exercise.id] = log.copyWith(id: _uuid.v4()) as ExerciseLog;
      });
    }
  }

  Future<void> _completeWorkout() async {
    if (_exerciseLogs.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final duration = _startTime != null ? DateTime.now().difference(_startTime!) : null;
      
      await context.read<WorkoutProvider>().logWorkout(
            sessionId: widget.session.id,
            sessionName: widget.session.name,
            exerciseLogs: _exerciseLogs.values.toList(),
            totalDuration: duration,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout completed! Great job! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
