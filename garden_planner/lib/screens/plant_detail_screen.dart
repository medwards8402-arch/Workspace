import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../services/schedule_service.dart';
import '../app_state.dart';
import '../presentation/providers/navigation_provider.dart';
import '../presentation/providers/library_navigation_provider.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final spring = ScheduleService.computeSpringSchedule(plant, state.zone);
    final fall = ScheduleService.computeFallSchedule(plant, state.zone);
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              // Set the plant in library navigation provider
              final libraryNav = context.read<LibraryNavigationProvider>();
              libraryNav.navigateToPlant(plant);
              // Navigate to library tab
              final navProvider = context.read<NavigationProvider>();
              navProvider.setIndex(3); // Library is at index 3
            },
            tooltip: 'View in Library',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [Text(plant.icon, style: const TextStyle(fontSize: 40)), const SizedBox(width: 12), Expanded(child: Text(plant.name, style: Theme.of(context).textTheme.headlineSmall))]),
          const SizedBox(height: 12),
          _sectionTitle('Spring Schedule'),
          _dateRow('Start Indoors', spring.indoor),
          _dateRow(plant.startIndoorsWeeks > 0 ? 'Transplant Outdoors' : 'Direct Sow', spring.sow),
          _dateRow('Harvest', spring.harvest),
          if (plant.supportsFall) ...[
            const SizedBox(height: 16),
            _sectionTitle('Fall Schedule'),
            _dateRow('Start Indoors', fall.indoor),
            _dateRow(plant.fallStartIndoorsWeeks > 0 ? 'Transplant Outdoors' : 'Direct Sow', fall.sow),
            _dateRow('Harvest', fall.harvest),
          ],
          const SizedBox(height: 16),
          _sectionTitle('Details'),
          _kv('Spacing', plant.cellsRequired != null && plant.cellsRequired! > 1 ? '1 / ${plant.cellsRequired} sqft (sprawling)' : '${plant.sqftSpacing} per sqft'),
          _kv('Light', plant.lightLevel),
          if (plant.tips.isNotEmpty) _kv('Tips', plant.tips.join('\n')),
          const SizedBox(height: 16),
          _sectionTitle('Notes'),
          TextFormField(
            initialValue: state.plantNotes[plant.code] ?? '',
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Your notes'),
            onChanged: (v) => state.updatePlantNote(plant.code, v.trim().isEmpty ? null : v.trim()),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(v))]),
      );
  Widget _dateRow(String label, DateTime? dt) => _kv(label, dt == null ? '—' : _fmt(dt));
  String _fmt(DateTime d) => '${_monthShort(d.month)} ${d.day}, ${d.year}';
  String _monthShort(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}
