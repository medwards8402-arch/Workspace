import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';

/// Form for logging reps-only exercises (bodyweight, bands)
class RepsOnlyForm extends StatefulWidget {
  final Exercise exercise;
  final RepsOnlyLog? prefillLog;

  const RepsOnlyForm({
    super.key,
    required this.exercise,
    this.prefillLog,
  });

  @override
  State<RepsOnlyForm> createState() => _RepsOnlyFormState();
}

class _RepsOnlyFormState extends State<RepsOnlyForm> {
  final _formKey = GlobalKey<FormState>();
  late int _sets;
  late List<TextEditingController> _repsControllers;
  Difficulty _difficulty = Difficulty.medium;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.prefillLog != null) {
      // Use pre-filled data
      _sets = widget.prefillLog!.sets;
      _repsControllers = widget.prefillLog!.repsPerSet
          .map((reps) => TextEditingController(text: reps.toString()))
          .toList();
      _difficulty = widget.prefillLog!.difficulty;
      _notesController.text = widget.prefillLog!.notes ?? '';
    } else {
      // Default values
      _sets = AppConstants.defaultSets;
      _repsControllers = List.generate(
        _sets,
        (_) => TextEditingController(text: '10'),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.cardBorderRadius),
                  topRight: Radius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.exercise.icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number of sets
                      Row(
                        children: [
                          Text(
                            'Sets: $_sets',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _sets > 1 ? _removeSets : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _addSet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Reps for each set
                      ...List.generate(_sets, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _repsControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Set ${index + 1} - Reps',
                              prefixIcon: const Icon(Icons.fitness_center),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter reps';
                              }
                              final reps = int.tryParse(value);
                              if (reps == null || reps < 1) {
                                return 'Must be at least 1';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Difficulty
                      Text(
                        'Difficulty',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<Difficulty>(
                        segments: const [
                          ButtonSegment(value: Difficulty.easy, label: Text('Easy'), icon: Icon(Icons.sentiment_satisfied)),
                          ButtonSegment(value: Difficulty.medium, label: Text('Medium'), icon: Icon(Icons.sentiment_neutral)),
                          ButtonSegment(value: Difficulty.hard, label: Text('Hard'), icon: Icon(Icons.sentiment_dissatisfied)),
                        ],
                        selected: {_difficulty},
                        onSelectionChanged: (Set<Difficulty> selection) {
                          setState(() {
                            _difficulty = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Tips for next time...',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSet() {
    setState(() {
      _sets++;
      _repsControllers.add(TextEditingController(text: '10'));
    });
  }

  void _removeSets() {
    if (_sets > 1) {
      setState(() {
        _sets--;
        _repsControllers.removeLast().dispose();
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repsPerSet = _repsControllers
        .map((c) => int.parse(c.text))
        .toList();

    final log = RepsOnlyLog(
      id: '', // Will be set by parent
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      difficulty: _difficulty,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      timestamp: DateTime.now(),
      sets: _sets,
      repsPerSet: repsPerSet,
    );

    Navigator.pop(context, log);
  }
}
