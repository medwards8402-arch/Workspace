import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'screens/garden_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => AppState(),
    child: const GardenPlannerApp(),
  ));
}

class GardenPlannerApp extends StatelessWidget {
  const GardenPlannerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static final List<Widget> _screens = const [
    GardenScreen(),
    PlantsScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(_titleForIndex(state.currentNavIndex))),
      body: _screens[state.currentNavIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentNavIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_on_outlined), label: 'Garden'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Plants'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: state.setNavIndex,
      ),
    );
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0:
        return 'Garden';
      case 1:
        return 'Plants';
      case 2:
        return 'Calendar';
      case 3:
        return 'Settings';
      default:
        return 'Garden Planner';
    }
  }
}
