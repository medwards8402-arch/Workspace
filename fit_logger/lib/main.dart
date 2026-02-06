import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/workout_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/exercises_screen.dart';
import 'presentation/screens/journal_screen.dart';
import 'data/models/exercise_hive.dart';
import 'data/models/workout_session_hive.dart';
import 'data/models/exercise_log_hive.dart';
import 'data/models/workout_log_hive.dart';
import 'data/models/duration_adapter.dart';
import 'data/models/planned_exercise_details_hive.dart';
import 'data/repositories/hive_workout_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(PlannedExerciseDetailsHiveAdapter());
  Hive.registerAdapter(ExerciseHiveAdapter());
  Hive.registerAdapter(WorkoutSessionHiveAdapter());
  Hive.registerAdapter(RepsOnlyLogHiveAdapter());
  Hive.registerAdapter(RepsWeightLogHiveAdapter());
  Hive.registerAdapter(TimeDistanceLogHiveAdapter());
  Hive.registerAdapter(IntervalsLogHiveAdapter());
  Hive.registerAdapter(WorkoutLogHiveAdapter());
  
  // Initialize repository
  final repository = HiveWorkoutRepository();
  await repository.initialize();
  
  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();
  
  runApp(FitLoggerApp(
    repository: repository,
    settingsProvider: settingsProvider,
  ));
}

class FitLoggerApp extends StatelessWidget {
  final HiveWorkoutRepository repository;
  final SettingsProvider settingsProvider;
  
  const FitLoggerApp({
    super.key,
    required this.repository,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(repository: repository)..initialize(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
              ),
            ),
            home: const RootShell(),
          );
        },
      ),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static final List<Widget> _screens = const [
    HomeScreen(),
    ExercisesScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: navProvider.currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navProvider.currentIndex,
        onDestinationSelected: navProvider.setIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Journal',
          ),
        ],
      ),
    );
  }
}
