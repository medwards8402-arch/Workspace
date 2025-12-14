import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/settings_provider.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Units Section
          _buildSectionHeader(context, 'Units'),
          Card(
            child: Column(
              children: [
                _buildUnitTile(
                  context: context,
                  title: 'Weight Unit',
                  subtitle: 'Choose your preferred weight measurement',
                  icon: Icons.fitness_center,
                  value: settings.useKg ? 'Kilograms (kg)' : 'Pounds (lbs)',
                  onTap: () => _showWeightUnitDialog(context),
                ),
                const Divider(height: 1),
                _buildUnitTile(
                  context: context,
                  title: 'Distance Unit',
                  subtitle: 'Choose your preferred distance measurement',
                  icon: Icons.straighten,
                  value: settings.useKm ? 'Kilometers (km)' : 'Miles (mi)',
                  onTap: () => _showDistanceUnitDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Week Settings Section
          _buildSectionHeader(context, 'Week Settings'),
          Card(
            child: _buildUnitTile(
              context: context,
              title: 'Week Start Day',
              subtitle: 'First day of your workout week',
              icon: Icons.calendar_today,
              value: _formatWeekDay(settings.weekStartDay),
              onTap: () => _showWeekStartDialog(context),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: _buildUnitTile(
              context: context,
              title: 'Theme Mode',
              subtitle: 'Choose light, dark, or system theme',
              icon: Icons.palette,
              value: _formatThemeMode(settings.themeMode),
              onTap: () => _showThemeModeDialog(context),
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Built with Flutter'),
                  subtitle: const Text('A progressive workout tracker'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Fit Logger',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.fitness_center, size: 48),
                      children: [
                        const Text('Track your workouts with smart pre-filling and progressive overload suggestions.'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader(context, 'Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete all workouts and sessions'),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildUnitTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showWeightUnitDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Kilograms (kg)'),
              value: true,
              groupValue: settings.useKg,
              onChanged: (value) {
                if (value != null) {
                  settings.setWeightUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('Pounds (lbs)'),
              value: false,
              groupValue: settings.useKg,
              onChanged: (value) {
                if (value != null) {
                  settings.setWeightUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDistanceUnitDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Kilometers (km)'),
              value: true,
              groupValue: settings.useKm,
              onChanged: (value) {
                if (value != null) {
                  settings.setDistanceUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('Miles (mi)'),
              value: false,
              groupValue: settings.useKm,
              onChanged: (value) {
                if (value != null) {
                  settings.setDistanceUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showWeekStartDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Week Start Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WeekDay.values.map((day) {
            return RadioListTile<WeekDay>(
              title: Text(_formatWeekDay(day)),
              value: day,
              groupValue: settings.weekStartDay,
              onChanged: (value) {
                if (value != null) {
                  settings.setWeekStartDay(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Week start day will update on next app restart'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system theme'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your workouts, sessions, and exercise history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data functionality coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  String _formatWeekDay(WeekDay day) {
    switch (day) {
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

  String _formatThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
