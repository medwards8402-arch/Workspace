import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/enums.dart';

/// Provider for app settings and preferences
class SettingsProvider with ChangeNotifier {
  static const String _settingsBoxName = 'settings';
  Box? _settingsBox;
  
  // Weight unit preference
  bool _useKg = true;
  
  // Distance unit preference
  bool _useKm = true;
  
  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;
  
  // First day of week
  WeekDay _weekStartDay = WeekDay.monday;
  
  // Getters
  bool get useKg => _useKg;
  bool get useKm => _useKm;
  ThemeMode get themeMode => _themeMode;
  WeekDay get weekStartDay => _weekStartDay;

  // ========== UNIT CONVERSIONS ==========

  /// Set weight unit (true = kg, false = lbs)
  void setWeightUnit(bool useKg) {
    _useKg = useKg;
    saveSettings();
    notifyListeners();
  }

  /// Set distance unit (true = km, false = mi)
  void setDistanceUnit(bool useKm) {
    _useKm = useKm;
    saveSettings();
    notifyListeners();
  }

  /// Convert weight from kg to display unit
  double convertWeightFromKg(double kgValue) {
    if (!_useKg) {
      return kgValue * 2.20462; // kg to lbs
    }
    return kgValue;
  }

  /// Convert weight from display unit to kg
  double convertWeightToKg(double displayValue) {
    if (!_useKg) {
      return displayValue / 2.20462; // lbs to kg
    }
    return displayValue;
  }

  /// Convert distance from km to display unit
  double convertDistanceFromKm(double kmValue) {
    if (!_useKm) {
      return kmValue * 0.621371; // km to miles
    }
    return kmValue;
  }

  /// Convert distance from display unit to km
  double convertDistanceToKm(double displayValue) {
    if (!_useKm) {
      return displayValue / 0.621371; // miles to km
    }
    return displayValue;
  }

  /// Get weight unit label
  String get weightUnitLabel => _useKg ? 'kg' : 'lbs';

  /// Get distance unit label
  String get distanceUnitLabel => _useKm ? 'km' : 'mi';

  /// Get speed unit label
  String get speedUnitLabel => '$distanceUnitLabel/h';

  /// Get pace unit label
  String get paceUnitLabel => 'min/$distanceUnitLabel';

  // ========== THEME ==========

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    saveSettings();
    notifyListeners();
  }

  // ========== WEEK START ==========

  /// Set week start day
  void setWeekStartDay(WeekDay day) {
    _weekStartDay = day;
    saveSettings();
    notifyListeners();
  }

  // ========== PERSISTENCE ==========

  /// Initialize and load settings from storage
  Future<void> initialize() async {
    try {
      _settingsBox = await Hive.openBox(_settingsBoxName);
      await loadSettings();
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  /// Load settings from Hive storage
  Future<void> loadSettings() async {
    if (_settingsBox == null) return;
    
    _useKg = _settingsBox!.get('useKg', defaultValue: true);
    _useKm = _settingsBox!.get('useKm', defaultValue: true);
    
    final themeModeIndex = _settingsBox!.get('themeMode', defaultValue: ThemeMode.system.index);
    _themeMode = ThemeMode.values[themeModeIndex];
    
    final weekStartIndex = _settingsBox!.get('weekStartDay', defaultValue: WeekDay.monday.index);
    _weekStartDay = WeekDay.values[weekStartIndex];
    
    notifyListeners();
  }

  /// Save settings to Hive storage
  Future<void> saveSettings() async {
    if (_settingsBox == null) return;
    
    await _settingsBox!.put('useKg', _useKg);
    await _settingsBox!.put('useKm', _useKm);
    await _settingsBox!.put('themeMode', _themeMode.index);
    await _settingsBox!.put('weekStartDay', _weekStartDay.index);
  }
}
