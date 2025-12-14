import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/workout_session.dart';
import '../../core/constants/app_constants.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_log_detail_widget.dart';

/// Screen displaying workout history and journal
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogs();
    });
  }

  Future<void> _loadLogs() async {
    final provider = context.read<WorkoutProvider>();
    await provider.loadLogsInRange(
      startDate: _startDate,
      endDate: _endDate,
      sessionId: _selectedSessionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final logs = workoutProvider.filteredLogs;
    final sessions = workoutProvider.activeSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: workoutProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Summary card
                    _buildSummaryCard(logs),
                    
                    // Filters chip row
                    _buildFilterChips(sessions),
                    
                    // Workout list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return _buildWorkoutCard(logs[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a workout to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<WorkoutLog> logs) {
    final totalWorkouts = logs.length;
    final totalExercises = logs.fold<int>(0, (sum, log) => sum + log.exerciseLogs.length);
    final totalDuration = logs.fold<Duration>(
      Duration.zero,
      (sum, log) => sum + (log.totalDuration ?? Duration.zero),
    );

    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              icon: Icons.fitness_center,
              label: 'Workouts',
              value: totalWorkouts.toString(),
              color: Colors.blue,
            ),
            _buildStat(
              icon: Icons.list_alt,
              label: 'Exercises',
              value: totalExercises.toString(),
              color: Colors.green,
            ),
            _buildStat(
              icon: Icons.timer,
              label: 'Total Time',
              value: _formatTotalDuration(totalDuration),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(List<WorkoutSession> sessions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: [
          // Date range chip
          ActionChip(
            avatar: const Icon(Icons.calendar_month, size: 18),
            label: Text(
              '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}',
            ),
            onPressed: _showDateRangePicker,
          ),
          const SizedBox(width: 8),
          
          // All sessions chip
          FilterChip(
            label: const Text('All Sessions'),
            selected: _selectedSessionId == null,
            onSelected: (selected) {
              setState(() {
                _selectedSessionId = null;
              });
              _loadLogs();
            },
          ),
          const SizedBox(width: 8),
          
          // Session filter chips
          ...sessions.map((session) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(session.name),
                selected: _selectedSessionId == session.id,
                onSelected: (selected) {
                  setState(() {
                    _selectedSessionId = selected ? session.id : null;
                  });
                  _loadLogs();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showWorkoutDetail(log),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Date badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(log.timestamp).toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          DateFormat('dd').format(log.timestamp),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Session name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.sessionName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(log.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // More options
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDelete(log);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Stats row
              Row(
                children: [
                  Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${log.exerciseLogs.length} exercises',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  if (log.totalDuration != null) ...[
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(log.totalDuration!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              
              // Notes preview
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  log.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetail(WorkoutLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WorkoutLogDetail(log: log),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Workouts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _showDateRangePicker,
              child: Text(
                '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
      _loadLogs();
    }
  }

  Future<void> _confirmDelete(WorkoutLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete workout from ${DateFormat('MMM d, yyyy').format(log.timestamp)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<WorkoutProvider>().deleteWorkoutLog(log.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
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

  String _formatTotalDuration(Duration duration) {
    final hours = duration.inHours;
    if (hours > 0) {
      return '${hours}h';
    }
    return '${duration.inMinutes}m';
  }
}
