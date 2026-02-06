import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/planned_exercise_details.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';

/// Widget for planning exercise details (sets, reps, weights, etc.)
class PlannedDetailsFormWidget extends StatefulWidget {
  final Exercise exercise;
  final PlannedExerciseDetails? existingDetails;
  final Function(PlannedExerciseDetails) onSave;

  const PlannedDetailsFormWidget({
    super.key,
    required this.exercise,
    this.existingDetails,
    required this.onSave,
  });

  @override
  State<PlannedDetailsFormWidget> createState() => _PlannedDetailsFormWidgetState();
}

class _PlannedDetailsFormWidgetState extends State<PlannedDetailsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;

  // For repsOnly and repsWeight
  int _sets = 3;
  List<int> _repsPerSet = [10, 10, 10];
  List<double> _weightsPerSet = [20.0, 20.0, 20.0];

  // For timeDistance
  int _durationMinutes = 30;
  int _durationSeconds = 0;
  double _distance = 5.0;

  // For intervals
  int _intervalCount = 5;
  List<Duration> _runDurations = [];
  List<Duration> _walkDurations = [];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();

    // Load existing details if available
    if (widget.existingDetails != null) {
      _loadExistingDetails();
    } else {
      _initializeDefaults();
    }
  }

  void _loadExistingDetails() {
    final details = widget.existingDetails!;
    _notesController.text = details.notes ?? '';

    switch (widget.exercise.measurementType) {
      case MeasurementType.repsOnly:
        _sets = details.plannedSets ?? 3;
        _repsPerSet = List<int>.from(details.plannedRepsPerSet ?? [10, 10, 10]);
        break;

      case MeasurementType.repsWeight:
        _sets = details.plannedSets ?? 3;
        _repsPerSet = List<int>.from(details.plannedRepsPerSet ?? [10, 10, 10]);
        _weightsPerSet = List<double>.from(details.plannedWeightsPerSet ?? [20.0, 20.0, 20.0]);
        break;

      case MeasurementType.timeDistance:
        if (details.plannedDuration != null) {
          _durationMinutes = details.plannedDuration!.inMinutes;
          _durationSeconds = details.plannedDuration!.inSeconds % 60;
        }
        _distance = details.plannedDistance ?? 5.0;
        break;

      case MeasurementType.intervals:
        _intervalCount = details.plannedIntervalCount ?? 5;
        _runDurations = List<Duration>.from(details.plannedRunDurations ?? []);
        _walkDurations = List<Duration>.from(details.plannedWalkDurations ?? []);
        if (_runDurations.isEmpty) _initializeIntervals();
        break;
    }
  }

  void _initializeDefaults() {
    switch (widget.exercise.measurementType) {
      case MeasurementType.intervals:
        _initializeIntervals();
        break;
      default:
        break;
    }
  }

  void _initializeIntervals() {
    _runDurations = List.generate(_intervalCount, (_) => const Duration(minutes: 2));
    _walkDurations = List.generate(_intervalCount, (_) => const Duration(minutes: 1));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateSets(int newSets) {
    setState(() {
      if (newSets > _sets) {
        // Add more sets
        for (int i = _sets; i < newSets; i++) {
          _repsPerSet.add(_repsPerSet.isNotEmpty ? _repsPerSet.last : 10);
          _weightsPerSet.add(_weightsPerSet.isNotEmpty ? _weightsPerSet.last : 20.0);
        }
      } else if (newSets < _sets) {
        // Remove sets
        _repsPerSet = _repsPerSet.sublist(0, newSets);
        _weightsPerSet = _weightsPerSet.sublist(0, newSets);
      }
      _sets = newSets;
    });
  }

  void _updateIntervalCount(int newCount) {
    setState(() {
      if (newCount > _intervalCount) {
        for (int i = _intervalCount; i < newCount; i++) {
          _runDurations.add(_runDurations.isNotEmpty ? _runDurations.last : const Duration(minutes: 2));
          _walkDurations.add(_walkDurations.isNotEmpty ? _walkDurations.last : const Duration(minutes: 1));
        }
      } else if (newCount < _intervalCount) {
        _runDurations = _runDurations.sublist(0, newCount);
        _walkDurations = _walkDurations.sublist(0, newCount);
      }
      _intervalCount = newCount;
    });
  }

  void _savePlannedDetails() {
    if (!_formKey.currentState!.validate()) return;

    PlannedExerciseDetails details;

    switch (widget.exercise.measurementType) {
      case MeasurementType.repsOnly:
        details = PlannedExerciseDetails.repsOnly(
          exerciseId: widget.exercise.id,
          sets: _sets,
          repsPerSet: _repsPerSet,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case MeasurementType.repsWeight:
        details = PlannedExerciseDetails.repsWeight(
          exerciseId: widget.exercise.id,
          sets: _sets,
          repsPerSet: _repsPerSet,
          weightsPerSet: _weightsPerSet,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case MeasurementType.timeDistance:
        details = PlannedExerciseDetails.timeDistance(
          exerciseId: widget.exercise.id,
          duration: Duration(minutes: _durationMinutes, seconds: _durationSeconds),
          distance: _distance,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case MeasurementType.intervals:
        details = PlannedExerciseDetails.intervals(
          exerciseId: widget.exercise.id,
          intervalCount: _intervalCount,
          runDurations: _runDurations,
          walkDurations: _walkDurations,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;
    }

    widget.onSave(details);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormContent(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.cardBorderRadius),
          topRight: Radius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Icon(widget.exercise.icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan: ${widget.exercise.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.exercise.measurementType.displayName,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widget.exercise.measurementType) {
      case MeasurementType.repsOnly:
        return _buildRepsOnlyForm();
      case MeasurementType.repsWeight:
        return _buildRepsWeightForm();
      case MeasurementType.timeDistance:
        return _buildTimeDistanceForm();
      case MeasurementType.intervals:
        return _buildIntervalsForm();
    }
  }

  Widget _buildRepsOnlyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sets', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _sets.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_sets sets',
          onChanged: (value) => _updateSets(value.toInt()),
        ),
        const SizedBox(height: 16),
        Text('Reps per Set', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._buildRepsInputs(),
      ],
    );
  }

  List<Widget> _buildRepsInputs() {
    return List.generate(_sets, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text('Set ${index + 1}:', style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              child: TextFormField(
                initialValue: _repsPerSet[index].toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  suffixText: 'reps',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _repsPerSet[index] = int.tryParse(value) ?? 10;
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRepsWeightForm() {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sets', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _sets.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_sets sets',
          onChanged: (value) => _updateSets(value.toInt()),
        ),
        const SizedBox(height: 16),
        Text('Reps & Weight per Set', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._buildRepsWeightInputs(settings),
      ],
    );
  }

  List<Widget> _buildRepsWeightInputs(SettingsProvider settings) {
    return List.generate(_sets, (index) {
      final displayWeight = settings.convertWeightFromKg(_weightsPerSet[index]);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text('Set ${index + 1}:', style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _repsPerSet[index].toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        suffixText: 'reps',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _repsPerSet[index] = int.tryParse(value) ?? 10;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: displayWeight.toStringAsFixed(1),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: settings.weightUnitLabel,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          final inputWeight = double.tryParse(value) ?? 20.0;
                          _weightsPerSet[index] = settings.convertWeightToKg(inputWeight);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeDistanceForm() {
    final settings = context.watch<SettingsProvider>();
    final displayDistance = settings.convertDistanceFromKm(_distance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _durationMinutes.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _durationMinutes = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _durationSeconds.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Seconds',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _durationSeconds = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Distance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: displayDistance.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: settings.distanceUnitLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              final inputDistance = double.tryParse(value) ?? 5.0;
              _distance = settings.convertDistanceToKm(inputDistance);
            });
          },
        ),
      ],
    );
  }

  Widget _buildIntervalsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Intervals', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _intervalCount.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          label: '$_intervalCount intervals',
          onChanged: (value) => _updateIntervalCount(value.toInt()),
        ),
        const SizedBox(height: 16),
        Text('Interval Durations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._buildIntervalInputs(),
      ],
    );
  }

  List<Widget> _buildIntervalInputs() {
    return List.generate(_intervalCount, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Interval ${index + 1}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _runDurations[index].inMinutes.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Run (min)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        final mins = int.tryParse(value) ?? 2;
                        _runDurations[index] = Duration(minutes: mins);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _walkDurations[index].inMinutes.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Walk (min)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        final mins = int.tryParse(value) ?? 1;
                        _walkDurations[index] = Duration(minutes: mins);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _savePlannedDetails,
            child: const Text('Save Plan'),
          ),
        ],
      ),
    );
  }
}
