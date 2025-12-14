import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/workout_session.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_picker_widget.dart';

/// Screen for creating or editing workout sessions
class SessionFormScreen extends StatefulWidget {
  final WorkoutSession? session;

  const SessionFormScreen({super.key, this.session});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  WeekDay? _selectedDay;
  List<String> _selectedExerciseIds = [];
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session?.name ?? '');
    _selectedDay = widget.session?.plannedDay;
    _selectedExerciseIds = List.from(widget.session?.exerciseIds ?? []);
    _isActive = widget.session?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.session != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Session' : 'New Session'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // Session name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name',
                hintText: 'e.g., Upper Body, Leg Day, Cardio',
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a session name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Day selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assign this session to a specific day or leave unscheduled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Unscheduled option
                        ChoiceChip(
                          label: const Text('Unscheduled'),
                          selected: _selectedDay == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDay = null;
                            });
                          },
                        ),
                        // Day options
                        ...WeekDay.values.map((day) => ChoiceChip(
                              label: Text(day.shortName),
                              selected: _selectedDay == day,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDay = selected ? day : null;
                                });
                              },
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Exercises section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton.icon(
                          onPressed: _showExercisePicker,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedExerciseIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No exercises added yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedExerciseIds.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _selectedExerciseIds.removeAt(oldIndex);
                            _selectedExerciseIds.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final exerciseId = _selectedExerciseIds[index];
                          final workoutProvider = context.read<WorkoutProvider>();
                          final exercise = workoutProvider._workoutService._repository
                              .getExercise(exerciseId);

                          return ListTile(
                            key: ValueKey(exerciseId),
                            leading: Icon(exercise?.icon ?? Icons.fitness_center),
                            title: Text(exercise?.name ?? 'Unknown'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedExerciseIds.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active toggle
            if (isEditing)
              SwitchListTile(
                title: const Text('Active Session'),
                subtitle: const Text(
                  'Inactive sessions won\'t appear in weekly checklist',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveSession,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(isEditing ? 'Save Changes' : 'Create Session'),
            ),

            // Delete button (only when editing)
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _deleteSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Session'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExercisePicker(
        selectedExerciseIds: _selectedExerciseIds,
        onExercisesSelected: (exerciseIds) {
          setState(() {
            _selectedExerciseIds = exerciseIds;
          });
        },
      ),
    );
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final workoutProvider = context.read<WorkoutProvider>();

    try {
      if (widget.session == null) {
        // Create new session
        await workoutProvider.createSession(
          name: _nameController.text.trim(),
          exerciseIds: _selectedExerciseIds,
          plannedDay: _selectedDay,
        );
      } else {
        // Update existing session
        final updated = widget.session!.copyWith(
          name: _nameController.text.trim(),
          exerciseIds: _selectedExerciseIds,
          plannedDay: _selectedDay,
          isActive: _isActive,
          clearPlannedDay: _selectedDay == null,
        );
        await workoutProvider.updateSession(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        SuccessSnackbar.show(
          context,
          widget.session == null
              ? 'Session created successfully'
              : 'Session updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this session? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.session != null) {
      setState(() {
        _isSaving = true;
      });

      try {
        await context.read<WorkoutProvider>().deleteSession(widget.session!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
