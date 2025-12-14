import '../domain/models/workout_session.dart';
import '../domain/repositories/workout_repository.dart';

/// Service for weekly reset functionality
class WeekResetService {
  final WorkoutRepository _repository;

  WeekResetService(this._repository);

  /// Check if sessions need weekly reset and perform if necessary
  Future<bool> checkAndResetWeek() async {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    
    final allSessions = await _repository.getAllSessions();
    bool anyReset = false;

    for (final session in allSessions) {
      // Check if session's week start is before current week
      if (session.weekStartDate.isBefore(currentWeekStart)) {
        final updated = session.reset(currentWeekStart);
        await _repository.saveSession(updated);
        anyReset = true;
      }
    }

    return anyReset;
  }

  /// Force reset all sessions (useful for testing or manual reset)
  Future<void> forceResetAllSessions() async {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    
    final allSessions = await _repository.getAllSessions();

    for (final session in allSessions) {
      final updated = session.reset(currentWeekStart);
      await _repository.saveSession(updated);
    }
  }

  /// Get sessions that need to be reset
  Future<List<WorkoutSession>> getSessionsNeedingReset() async {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    
    final allSessions = await _repository.getAllSessions();
    
    return allSessions
        .where((session) => session.weekStartDate.isBefore(currentWeekStart))
        .toList();
  }

  /// Check if it's a new week (Monday)
  bool isNewWeek() {
    return DateTime.now().weekday == DateTime.monday;
  }

  /// Get the Monday of the current week for a given date
  DateTime _getWeekStartDate(DateTime date) {
    // Monday = 1, Sunday = 7
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1; // 0 for Monday, 1 for Tuesday, etc.
    final monday = date.subtract(Duration(days: daysToSubtract));
    
    // Return Monday at midnight
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get current week start date
  DateTime getCurrentWeekStart() {
    return _getWeekStartDate(DateTime.now());
  }

  /// Get next week start date
  DateTime getNextWeekStart() {
    final currentWeekStart = getCurrentWeekStart();
    return currentWeekStart.add(const Duration(days: 7));
  }

  /// Get days until next reset (days until Monday)
  int getDaysUntilReset() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    
    if (weekday == DateTime.monday) {
      return 7; // Today is Monday, next reset is in 7 days
    }
    
    return 8 - weekday; // Days remaining in week
  }

  /// Get completion summary for current week
  Future<WeekCompletionSummary> getWeekCompletionSummary() async {
    final activeSessions = await _repository.getActiveSessions();
    
    int total = activeSessions.length;
    int completed = activeSessions.where((s) => s.completedThisWeek).length;
    int remaining = total - completed;

    return WeekCompletionSummary(
      total: total,
      completed: completed,
      remaining: remaining,
      completionRate: total > 0 ? completed / total : 0.0,
    );
  }

  /// Get sessions completed this week
  Future<List<WorkoutSession>> getCompletedThisWeek() async {
    final activeSessions = await _repository.getActiveSessions();
    return activeSessions.where((s) => s.completedThisWeek).toList();
  }

  /// Get sessions not completed this week
  Future<List<WorkoutSession>> getIncompleteThisWeek() async {
    final activeSessions = await _repository.getActiveSessions();
    return activeSessions.where((s) => !s.completedThisWeek).toList();
  }
}

/// Summary of weekly completion status
class WeekCompletionSummary {
  final int total;
  final int completed;
  final int remaining;
  final double completionRate;

  WeekCompletionSummary({
    required this.total,
    required this.completed,
    required this.remaining,
    required this.completionRate,
  });

  bool get allCompleted => remaining == 0 && total > 0;
  bool get noneCompleted => completed == 0;
  String get percentageString => '${(completionRate * 100).toStringAsFixed(0)}%';
}
