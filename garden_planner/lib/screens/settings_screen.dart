import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('USDA Zone'),
        DropdownButton<String>(
          value: state.zone,
          items: usdaZones.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
          onChanged: (v) => state.setZone(v!),
        ),
        const SizedBox(height: 24),
        Text('Placed Plants (${state.uniquePlacedPlants().length})', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: state.uniquePlacedPlants().map((p) => Chip(label: Text(p.name), avatar: Text(p.icon))).toList(),
        ),
      ],
    );
  }
}
