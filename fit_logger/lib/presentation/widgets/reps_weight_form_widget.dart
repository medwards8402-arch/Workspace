import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/settings_provider.dart';

/// Form for logging weighted exercises (barbell, dumbbell, kettlebell, medicine ball)
class RepsWeightForm extends StatefulWidget {
  final Exercise exercise;
  final RepsWeightLog? prefillLog;

  const RepsWeightForm({
    super.key,
    required this.exercise,
    this.prefillLog,
  });

  @override
  State<RepsWeightForm> createState() => _RepsWeightFormState();
}

class _RepsWeightFormState extends State<RepsWeightForm> {
  final _formKey = GlobalKey<FormState>();
  late int _sets;
  late List<TextEditingController> _repsControllers;
  late List<TextEditingController> _weightControllers;
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
      _weightControllers = widget.prefillLog!.weightsPerSet
          .map((weight) => TextEditingController(text: weight.toString()))
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
      _weightControllers = List.generate(
        _sets,
        (_) => TextEditingController(text: '20'),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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
                            onPressed: _sets > 1 ? _removeSet : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _addSet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Each set: reps and weight
                      ...List.generate(_sets, (index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set ${index + 1}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _repsControllers[index],
                                        decoration: const InputDecoration(
                                          labelText: 'Reps',
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          final reps = int.tryParse(value);
                                          if (reps == null || reps < 1) return 'Min 1';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _weightControllers[index],
                                        decoration: InputDecoration(
                                          labelText: 'Weight (${settings.weightUnitLabel})',
                                          isDense: true,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          final weight = double.tryParse(value);
                                          if (weight == null || weight <= 0) return 'Min 0.1';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      // Copy last weight as default
      final lastWeight = _weightControllers.isNotEmpty ? _weightControllers.last.text : '20';
      _weightControllers.add(TextEditingController(text: lastWeight));
    });
  }

  void _removeSet() {
    if (_sets > 1) {
      setState(() {
        _sets--;
        _repsControllers.removeLast().dispose();
        _weightControllers.removeLast().dispose();
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<SettingsProvider>();
    final repsPerSet = _repsControllers.map((c) => int.parse(c.text)).toList();
    final weightsPerSet = _weightControllers
        .map((c) => settings.convertWeightToKg(double.parse(c.text)))
        .toList();

    final log = RepsWeightLog(
      id: '',
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      difficulty: _difficulty,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      timestamp: DateTime.now(),
      sets: _sets,
      repsPerSet: repsPerSet,
      weightsPerSet: weightsPerSet,
    );

    Navigator.pop(context, log);
  }
}
