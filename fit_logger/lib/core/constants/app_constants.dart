import 'enums.dart';

/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'Fit Logger';
  static const String appVersion = '1.0.0';

  // Weekly reset
  static const WeekDay weekStartDay = WeekDay.monday;

  // Default values
  static const int defaultSets = 3;
  static const int defaultRestSeconds = 60;

  // Hive box names
  static const String sessionsBox = 'workout_sessions';
  static const String logsBox = 'workout_logs';
  static const String settingsBox = 'settings';

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Units
  static const String defaultWeightUnit = 'kg';
  static const String defaultDistanceUnit = 'km';
  static const String defaultSpeedUnit = 'km/h';

  // UI constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
}
