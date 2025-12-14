import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_tile_widget.dart';
import '../widgets/exercise_detail_widget.dart';

/// Exercises library screen
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _searchQuery = '';
  ExerciseCategory? _filterCategory;
  MeasurementType? _filterMeasurementType;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final allExercises = workoutProvider.workoutService.repository.getAllExercises();

    // Apply filters
    var filteredExercises = _applyFilters(allExercises);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All Categories'),
                    selected: _filterCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _filterCategory = null;
                      });
                    },
                  ),
                ),
                ...ExerciseCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: _filterCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _filterCategory = _filterCategory == category ? null : category;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Measurement type filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All Types'),
                    selected: _filterMeasurementType == null,
                    onSelected: (_) {
                      setState(() {
                        _filterMeasurementType = null;
                      });
                    },
                  ),
                ),
                ...MeasurementType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: _filterMeasurementType == type,
                      onSelected: (_) {
                        setState(() {
                          _filterMeasurementType = _filterMeasurementType == type ? null : type;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredExercises.length} ${filteredExercises.length == 1 ? 'exercise' : 'exercises'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (_filterCategory != null || _filterMeasurementType != null || _searchQuery.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterCategory = null;
                        _filterMeasurementType = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Exercise list/grid
          Expanded(
            child: filteredExercises.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView(filteredExercises)
                    : _buildListView(filteredExercises),
          ),
        ],
      ),
    );
  }

  List<Exercise> _applyFilters(List<Exercise> exercises) {
    var filtered = exercises;

    // Category filter
    if (_filterCategory != null) {
      filtered = filtered.where((e) => e.category == _filterCategory).toList();
    }

    // Measurement type filter
    if (_filterMeasurementType != null) {
      filtered = filtered.where((e) => e.measurementType == _filterMeasurementType).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.name.toLowerCase().contains(query) ||
            e.category.displayName.toLowerCase().contains(query) ||
            e.muscleGroups.any((mg) => mg.toLowerCase().contains(query)) ||
            e.equipment.any((eq) => eq.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Exercise> exercises) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return ExerciseTile(
          exercise: exercises[index],
          isGridView: true,
          onTap: () => _showExerciseDetail(exercises[index]),
        );
      },
    );
  }

  Widget _buildListView(List<Exercise> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ExerciseTile(
            exercise: exercises[index],
            isGridView: false,
            onTap: () => _showExerciseDetail(exercises[index]),
          ),
        );
      },
    );
  }

  void _showExerciseDetail(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExerciseDetail(exercise: exercise),
    );
  }
}
