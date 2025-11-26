import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/garden_repository_impl.dart';
import 'data/sources/local_storage.dart';
import 'domain/repositories/garden_repository.dart';
import 'presentation/providers/garden_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/plant_notes_provider.dart';
import 'presentation/providers/plant_selection_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'screens/garden_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorage.create();
  runApp(GardenPlannerApp(storage: storage));
}

class GardenPlannerApp extends StatelessWidget {
  final LocalStorage storage;
  
  const GardenPlannerApp({super.key, required this.storage});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Create repository
        Provider<GardenRepository>(
          create: (_) => GardenRepositoryImpl(storage),
        ),
        // Create providers
        ChangeNotifierProxyProvider<GardenRepository, GardenProvider>(
          create: (context) => GardenProvider(context.read<GardenRepository>()),
          update: (context, repository, previous) => 
            previous ?? GardenProvider(repository),
        ),
        ChangeNotifierProxyProvider<GardenRepository, SettingsProvider>(
          create: (context) => SettingsProvider(context.read<GardenRepository>()),
          update: (context, repository, previous) => 
            previous ?? SettingsProvider(repository),
        ),
        ChangeNotifierProxyProvider<GardenRepository, PlantNotesProvider>(
          create: (context) => PlantNotesProvider(context.read<GardenRepository>()),
          update: (context, repository, previous) => 
            previous ?? PlantNotesProvider(repository),
        ),
        ChangeNotifierProvider(create: (_) => PlantSelectionProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Garden Planner',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const RootShell(),
      ),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static final GlobalKey<LibraryScreenState> libraryKey = GlobalKey<LibraryScreenState>();

  static final List<Widget> _screens = [
    const PlantsScreen(),
    const GardenScreen(),
    const CalendarScreen(),
    LibraryScreen(key: libraryKey),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<NavigationProvider>();
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: navState.currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navState.currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Plants'),
          NavigationDestination(icon: Icon(Icons.grid_on_outlined), label: 'Garden'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: navState.setIndex,
      ),
    );
  }
}
