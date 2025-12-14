import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/session_card_widget.dart';
import '../widgets/common_widgets.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import 'session_form_screen.dart';
import 'settings_screen.dart';

/// Home screen showing weekly workout sessions checklist
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load sessions when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Week'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<WorkoutProvider>().loadSessions();
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.isLoading) {
            return const LoadingWidget(message: 'Loading your workouts...');
          }

          if (workoutProvider.error != null) {
            return ErrorStateWidget(
              message: workoutProvider.error!,
              onRetry: () {
                workoutProvider.clearError();
                workoutProvider.loadSessions();
              },
            );
          }

          return FutureBuilder<Map<WeekDay, List>>(
            future: workoutProvider.getSessionsByWeek(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final sessionsByDay = snapshot.data!;
              
              return RefreshIndicator(
                onRefresh: () => workoutProvider.loadSessions(),
                child: CustomScrollView(
                  slivers: [
                    // Week summary card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: _buildWeekSummaryCard(context, workoutProvider),
                      ),
                    ),
                    
                    // Daily sessions
                    ...WeekDay.values.map((day) {
                      final sessions = sessionsByDay[day] ?? [];
                      return _buildDaySection(context, day, sessions);
                    }).toList(),
                    
                    // Unscheduled sessions
                    SliverToBoxAdapter(
                      child: FutureBuilder<List>(
                        future: workoutProvider.getUnscheduledSessions(),
                        builder: (context, unscheduledSnapshot) {
                          if (!unscheduledSnapshot.hasData ||
                              unscheduledSnapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          return _buildUnscheduledSection(
                            context,
                            unscheduledSnapshot.data!,
                          );
                        },
                      ),
                    ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateSession(context),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildWeekSummaryCard(BuildContext context, WorkoutProvider provider) {
    return FutureBuilder(
      future: Future.wait([
        provider.getWeekSummary(),
        provider.getWorkoutsThisWeek(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final summary = snapshot.data![0];
        final workoutsCount = snapshot.data![1] as int;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      context,
                      'Completed',
                      '${summary.completed}/${summary.total}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildSummaryItem(
                      context,
                      'Progress',
                      summary.percentageString,
                      Icons.trending_up,
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildSummaryItem(
                      context,
                      'Workouts',
                      workoutsCount.toString(),
                      Icons.fitness_center,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildDaySection(BuildContext context, WeekDay day, List sessions) {
    final isToday = DateTime.now().weekday == day.weekdayNumber;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  day.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TODAY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No sessions scheduled',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              )
            else
              ...sessions.map((session) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.smallPadding,
                    ),
                    child: SessionCard(session: session),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildUnscheduledSection(BuildContext context, List sessions) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unscheduled',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          ...sessions.map((session) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.smallPadding,
                ),
                child: SessionCard(session: session),
              )),
        ],
      ),
    );
  }

  void _navigateToCreateSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SessionFormScreen(),
      ),
    );
  }
}
