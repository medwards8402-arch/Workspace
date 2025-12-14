import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import '../providers/workout_provider.dart';

/// Bottom sheet for selecting exercises to add to a session
class ExercisePicker extends StatefulWidget {
  final List<String> selectedExerciseIds;
  final Function(List<String>) onExercisesSelected;

  const ExercisePicker({
    super.key,
    required this.selectedExerciseIds,
    required this.onExercisesSelected,
  });

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  late List<String> _tempSelected;
  String _searchQuery = '';
  ExerciseCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedExerciseIds);
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.read<WorkoutProvider>();
    final allExercises = workoutProvider.workoutService.repository.getAllExercises();

    // Filter exercises
    var filteredExercises = allExercises;
    if (_filterCategory != null) {
      filteredExercises = filteredExercises
          .where((e) => e.category == _filterCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredExercises = filteredExercises.where((e) {
        return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.muscleGroups.any(
              (mg) => mg.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Exercises',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onExercisesSelected(_tempSelected);
                      Navigator.pop(context);
                    },
                    child: Text('Done (${_tempSelected.length})'),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
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
            const SizedBox(height: 12),

            // Category filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _filterCategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...ExerciseCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.displayName),
                        selected: _filterCategory == category,
                        onSelected: (_) {
                          setState(() {
                            _filterCategory =
                                _filterCategory == category ? null : category;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Exercise list
            Expanded(
              child: filteredExercises.isEmpty
                  ? Center(
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
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        final isSelected = _tempSelected.contains(exercise.id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _tempSelected.add(exercise.id);
                              } else {
                                _tempSelected.remove(exercise.id);
                              }
                            });
                          },
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${exercise.category.displayName} • ${exercise.muscleGroups.join(", ")}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          secondary: Icon(exercise.icon),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
