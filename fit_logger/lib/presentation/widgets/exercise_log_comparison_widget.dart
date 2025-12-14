import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/exercise_log.dart';
import '../../domain/models/workout_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';

/// Widget showing comparison of exercise performance over time
class ExerciseLogComparison extends StatefulWidget {
  final String sessionId;
  final String exerciseId;
  final ExerciseLog currentLog;

  const ExerciseLogComparison({
    super.key,
    required this.sessionId,
    required this.exerciseId,
    required this.currentLog,
  });

  @override
  State<ExerciseLogComparison> createState() => _ExerciseLogComparisonState();
}

class _ExerciseLogComparisonState extends State<ExerciseLogComparison> {
  List<ExerciseLog> _previousLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousLogs();
  }

  Future<void> _loadPreviousLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = context.read<WorkoutProvider>();
      final logs = await provider.getExerciseHistory(
        sessionId: widget.sessionId,
        exerciseId: widget.exerciseId,
        limit: 10,
      );
      
      setState(() {
        _previousLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentLog.exerciseName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Performance History',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _previousLogs.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            children: [
                              // Current workout (highlighted)
                              _buildCurrentLogCard(),
                              const SizedBox(height: 16),
                              
                              // Previous workouts
                              if (_previousLogs.isNotEmpty) ...[
                                Text(
                                  'Previous Workouts',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                ..._previousLogs.map((log) => _buildPreviousLogCard(log)),
                              ],
                              
                              // Progress insights
                              if (_previousLogs.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildProgressInsights(),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No previous workouts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more workouts to see comparisons',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLogCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLogDetails(widget.currentLog),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousLogCard(ExerciseLog log) {
    final comparison = widget.currentLog.compareTo(log);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MMM d, yyyy').format(log.timestamp),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                _buildComparisonBadge(comparison),
              ],
            ),
            const SizedBox(height: 8),
            _buildLogDetails(log),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetails(ExerciseLog log) {
    final settings = context.watch<SettingsProvider>();
    
    return switch (log) {
      RepsOnlyLog() => _buildRepsOnlyLogDetails(log),
      RepsWeightLog() => _buildRepsWeightLogDetails(log, settings),
      TimeDistanceLog() => _buildTimeDistanceLogDetails(log, settings),
      IntervalsLog() => _buildIntervalsLogDetails(log),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildRepsOnlyLogDetails(RepsOnlyLog log) {
    final totalReps = log.repsPerSet.fold<int>(0, (sum, reps) => sum + reps);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${log.repsPerSet.length} sets • $totalReps total reps'),
        const SizedBox(height: 4),
        Text(
          log.repsPerSet.join(' - '),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildRepsWeightLogDetails(RepsWeightLog log, SettingsProvider settings) {
    final totalReps = log.repsPerSet.fold<int>(0, (sum, reps) => sum + reps);
    final avgWeight = log.weightsPerSet.reduce((a, b) => a + b) / log.weightsPerSet.length;
    final displayWeight = settings.convertWeightFromKg(avgWeight);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${log.repsPerSet.length} sets • $totalReps total reps'),
        Text('Avg weight: ${displayWeight.toStringAsFixed(1)} ${settings.weightUnitLabel}'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: List.generate(log.repsPerSet.length, (i) {
            final displayWeight = settings.convertWeightFromKg(log.weightsPerSet[i]);
            return Text(
              '${log.repsPerSet[i]}×${displayWeight.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeDistanceLogDetails(TimeDistanceLog log, SettingsProvider settings) {
    final displayDistance = settings.convertDistanceFromKm(log.distance);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_formatDuration(log.duration)} • ${displayDistance.toStringAsFixed(2)} ${settings.distanceUnitLabel}'),
        if (log.pace != null)
          Text(
            'Pace: ${log.pace!.toStringAsFixed(2)} min/${settings.distanceUnitLabel}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
      ],
    );
  }

  Widget _buildIntervalsLogDetails(IntervalsLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${log.intervalCount} intervals'),
        Text(
          'Total: ${_formatDuration(log.totalDuration)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildComparisonBadge(int comparison) {
    if (comparison == 0) {
      return Chip(
        label: const Text('Same', style: TextStyle(fontSize: 11)),
        avatar: const Icon(Icons.remove, size: 14),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.grey[300],
      );
    } else if (comparison > 0) {
      return Chip(
        label: const Text('Improved', style: TextStyle(fontSize: 11)),
        avatar: const Icon(Icons.trending_up, size: 14),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.green[100],
      );
    } else {
      return Chip(
        label: const Text('Less', style: TextStyle(fontSize: 11)),
        avatar: const Icon(Icons.trending_down, size: 14),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.orange[100],
      );
    }
  }

  Widget _buildProgressInsights() {
    if (_previousLogs.isEmpty) return const SizedBox.shrink();
    
    final improvements = _previousLogs.where((log) => widget.currentLog.compareTo(log) > 0).length;
    final total = _previousLogs.length;
    final improvementRate = (improvements / total * 100).round();
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Progress Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              improvements > 0
                  ? '🎉 You\'ve improved in $improvements of the last $total workouts ($improvementRate%)'
                  : 'Keep pushing! Progress takes time and consistency.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[900],
                  ),
            ),
            const SizedBox(height: 8),
            _buildProgressTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTip() {
    final lastDifficulty = _previousLogs.isNotEmpty ? _previousLogs.first.difficulty : Difficulty.medium;
    String tip = '';
    
    if (widget.currentLog.difficulty == Difficulty.hard) {
      tip = '💪 Hard workout! Consider maintaining this level or taking active recovery.';
    } else if (widget.currentLog.difficulty == Difficulty.easy && lastDifficulty != Difficulty.hard) {
      tip = '⬆️ Ready to increase intensity? Try adding reps or weight next time.';
    } else {
      tip = '✨ Consistent effort leads to results. Keep it up!';
    }
    
    return Text(
      tip,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.blue[800],
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
