/// Exercise categories for grouping and filtering
enum ExerciseCategory {
  bodyweight,
  barbell,
  dumbbell,
  kettlebell,
  band,
  medicineBall,
  cardio,
}

/// Types of measurements for different exercise types
enum MeasurementType {
  repsOnly,      // Bodyweight exercises (pushups, pullups)
  repsWeight,    // Weighted exercises (squats, bench press)
  timeDistance,  // Cardio (running, swimming, biking)
  intervals,     // Interval training (HIIT, run/walk combos)
}

/// Extension methods for MeasurementType
extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.repsOnly:
        return 'Reps Only';
      case MeasurementType.repsWeight:
        return 'Reps & Weight';
      case MeasurementType.timeDistance:
        return 'Time & Distance';
      case MeasurementType.intervals:
        return 'Intervals';
    }
  }
}

/// Difficulty rating for progressive overload tracking
enum Difficulty {
  easy,
  medium,
  hard,
}

/// Days of the week for session planning
enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Extension methods for WeekDay
extension WeekDayExtension on WeekDay {
  String get displayName {
    switch (this) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
      case WeekDay.sunday:
        return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
      case WeekDay.sunday:
        return 'Sun';
    }
  }

  int get weekdayNumber {
    return index + 1; // 1-7 for Monday-Sunday
  }
}

/// Extension methods for ExerciseCategory
extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.bodyweight:
        return 'Bodyweight';
      case ExerciseCategory.barbell:
        return 'Barbell';
      case ExerciseCategory.dumbbell:
        return 'Dumbbell';
      case ExerciseCategory.kettlebell:
        return 'Kettlebell';
      case ExerciseCategory.band:
        return 'Resistance Band';
      case ExerciseCategory.medicineBall:
        return 'Medicine Ball';
      case ExerciseCategory.cardio:
        return 'Cardio';
    }
  }
}

/// Extension methods for Difficulty
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
