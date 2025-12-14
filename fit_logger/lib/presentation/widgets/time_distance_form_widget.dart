import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/settings_provider.dart';

/// Form for logging cardio exercises with time/distance
class TimeDistanceForm extends StatefulWidget {
  final Exercise exercise;
  final TimeDistanceLog? prefillLog;

  const TimeDistanceForm({
    super.key,
    required this.exercise,
    this.prefillLog,
  });

  @override
  State<TimeDistanceForm> createState() => _TimeDistanceFormState();
}

class _TimeDistanceFormState extends State<TimeDistanceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  Difficulty _difficulty = Difficulty.medium;
  bool _includeSpeed = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.prefillLog != null) {
      final duration = widget.prefillLog!.duration;
      _minutesController.text = duration.inMinutes.toString();
      _secondsController.text = duration.inSeconds.remainder(60).toString();
      _distanceController.text = widget.prefillLog!.distance.toString();
      if (widget.prefillLog!.speed != null) {
        _speedController.text = widget.prefillLog!.speed.toString();
        _includeSpeed = true;
      }
      _difficulty = widget.prefillLog!.difficulty;
      _notesController.text = widget.prefillLog!.notes ?? '';
    } else {
      _minutesController.text = '30';
      _secondsController.text = '0';
      _distanceController.text = '5.0';
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _distanceController.dispose();
    _speedController.dispose();
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
                      // Duration
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minutesController,
                              decoration: const InputDecoration(
                                labelText: 'Minutes',
                                suffixText: 'min',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                final mins = int.tryParse(value);
                                if (mins == null || mins < 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _secondsController,
                              decoration: const InputDecoration(
                                labelText: 'Seconds',
                                suffixText: 'sec',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                final secs = int.tryParse(value);
                                if (secs == null || secs < 0 || secs >= 60) return '0-59';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Distance
                      TextFormField(
                        controller: _distanceController,
                        decoration: InputDecoration(
                          labelText: 'Distance',
                          suffixText: settings.distanceUnitLabel,
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final distance = double.tryParse(value);
                          if (distance == null || distance <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Optional speed
                      SwitchListTile(
                        title: const Text('Track Speed'),
                        value: _includeSpeed,
                        onChanged: (value) {
                          setState(() {
                            _includeSpeed = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_includeSpeed) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _speedController,
                          decoration: InputDecoration(
                            labelText: 'Speed',
                            suffixText: settings.speedUnitLabel,
                            prefixIcon: const Icon(Icons.speed),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (!_includeSpeed) return null;
                            if (value == null || value.isEmpty) return 'Required';
                            final speed = double.tryParse(value);
                            if (speed == null || speed <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ],
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
                          hintText: 'How did it feel?',
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<SettingsProvider>();
    final duration = Duration(
      minutes: int.parse(_minutesController.text),
      seconds: int.parse(_secondsController.text),
    );
    final distance = settings.convertDistanceToKm(double.parse(_distanceController.text));
    final speed = _includeSpeed && _speedController.text.isNotEmpty
        ? settings.convertDistanceToKm(double.parse(_speedController.text))
        : null;

    final log = TimeDistanceLog(
      id: '',
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      difficulty: _difficulty,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      timestamp: DateTime.now(),
      duration: duration,
      distance: distance,
      speed: speed,
    );

    Navigator.pop(context, log);
  }
}
