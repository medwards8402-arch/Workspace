import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../providers/settings_provider.dart';

/// Form for logging interval training exercises
class IntervalsForm extends StatefulWidget {
  final Exercise exercise;
  final IntervalsLog? prefillLog;

  const IntervalsForm({
    super.key,
    required this.exercise,
    this.prefillLog,
  });

  @override
  State<IntervalsForm> createState() => _IntervalsFormState();
}

class _IntervalsFormState extends State<IntervalsForm> {
  final _formKey = GlobalKey<FormState>();
  late int _intervalCount;
  late List<_IntervalData> _intervals;
  Difficulty _difficulty = Difficulty.medium;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.prefillLog != null) {
      _intervalCount = widget.prefillLog!.intervalCount;
      _intervals = List.generate(_intervalCount, (i) {
        return _IntervalData(
          runMinutes: widget.prefillLog!.runDurations[i].inMinutes,
          runSeconds: widget.prefillLog!.runDurations[i].inSeconds.remainder(60),
          walkMinutes: widget.prefillLog!.walkDurations[i].inMinutes,
          walkSeconds: widget.prefillLog!.walkDurations[i].inSeconds.remainder(60),
          speed: widget.prefillLog!.speeds[i],
        );
      });
      _difficulty = widget.prefillLog!.difficulty;
      _notesController.text = widget.prefillLog!.notes ?? '';
    } else {
      _intervalCount = 4;
      _intervals = List.generate(4, (_) => _IntervalData());
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
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
                      // Number of intervals
                      Row(
                        children: [
                          Text(
                            'Intervals: $_intervalCount',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _intervalCount > 1 ? _removeInterval : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _addInterval,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Each interval
                      ...List.generate(_intervalCount, (index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Interval ${index + 1}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Run duration
                                Text('Run Duration', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _intervals[index].runMinutes.toString(),
                                        decoration: const InputDecoration(
                                          labelText: 'Min',
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (value) {
                                          _intervals[index].runMinutes = int.tryParse(value) ?? 0;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _intervals[index].runSeconds.toString(),
                                        decoration: const InputDecoration(
                                          labelText: 'Sec',
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (value) {
                                          _intervals[index].runSeconds = int.tryParse(value) ?? 0;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          final secs = int.tryParse(value);
                                          if (secs == null || secs >= 60) return '0-59';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Walk duration
                                Text('Walk/Rest Duration', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _intervals[index].walkMinutes.toString(),
                                        decoration: const InputDecoration(
                                          labelText: 'Min',
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (value) {
                                          _intervals[index].walkMinutes = int.tryParse(value) ?? 0;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _intervals[index].walkSeconds.toString(),
                                        decoration: const InputDecoration(
                                          labelText: 'Sec',
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (value) {
                                          _intervals[index].walkSeconds = int.tryParse(value) ?? 0;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Required';
                                          final secs = int.tryParse(value);
                                          if (secs == null || secs >= 60) return '0-59';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Speed
                                TextFormField(
                                  initialValue: _intervals[index].speed.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Speed (${settings.speedUnitLabel})',
                                    isDense: true,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  onChanged: (value) {
                                    _intervals[index].speed = double.tryParse(value) ?? 0;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Required';
                                    final speed = double.tryParse(value);
                                    if (speed == null || speed <= 0) return 'Must be > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

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

  void _addInterval() {
    setState(() {
      _intervalCount++;
      _intervals.add(_IntervalData());
    });
  }

  void _removeInterval() {
    if (_intervalCount > 1) {
      setState(() {
        _intervalCount--;
        _intervals.removeLast();
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<SettingsProvider>();
    
    final runDurations = _intervals.map((i) {
      return Duration(minutes: i.runMinutes, seconds: i.runSeconds);
    }).toList();
    
    final walkDurations = _intervals.map((i) {
      return Duration(minutes: i.walkMinutes, seconds: i.walkSeconds);
    }).toList();
    
    final speeds = _intervals.map((i) {
      return settings.convertDistanceToKm(i.speed);
    }).toList();

    final log = IntervalsLog(
      id: '',
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      difficulty: _difficulty,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      timestamp: DateTime.now(),
      intervalCount: _intervalCount,
      runDurations: runDurations,
      walkDurations: walkDurations,
      speeds: speeds,
    );

    Navigator.pop(context, log);
  }
}

class _IntervalData {
  int runMinutes;
  int runSeconds;
  int walkMinutes;
  int walkSeconds;
  double speed;

  _IntervalData({
    this.runMinutes = 2,
    this.runSeconds = 0,
    this.walkMinutes = 1,
    this.walkSeconds = 0,
    this.speed = 10.0,
  });
}
