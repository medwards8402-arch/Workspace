import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';
import '../widgets/tip.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Garden Setup', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Tip(
          id: 'settings-getting-started',
          message: '1. Set your garden name and zone below\n'
                  '2. Configure your raised beds (add, edit, or remove)\n'
                  '3. Go to Plants tab to select plants\n'
                  '4. Go to Garden tab to place plants in beds\n'
                  '5. View Calendar tab to see your planting schedule',
        ),
        const SizedBox(height: 16),
        
        // Garden name
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Garden Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: state.gardenName)..selection = TextSelection.fromPosition(TextPosition(offset: state.gardenName.length)),
                  onSubmitted: (v) => state.setGardenName(v),
                  decoration: const InputDecoration(
                    hintText: 'My Garden',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Zone
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('USDA Hardiness Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Sets planting dates for your location', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: state.zone,
                  isExpanded: true,
                  items: usdaZones.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (v) => state.setZone(v!),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Bed management
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raised Beds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Configure your garden layout', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => _showAddBedDialog(context, state),
                      tooltip: 'Add new bed',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...state.beds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bed = entry.value;
                  return Card(
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(bed.name),
                      subtitle: Text('${bed.rows} rows × ${bed.cols} cols'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditBedDialog(context, state, index, bed),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _confirmDeleteBed(context, state, index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Placed plants
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Placed Plants (${state.uniquePlacedPlants().length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.uniquePlacedPlants().map((p) => Chip(label: Text(p.name), avatar: Text(p.icon))).toList(),
                ),
              ],
            ),
          ),
        ),
        
        // Tips Management
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tips & Hints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Manage helpful tips shown throughout the app', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        state.resetAllTips();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All tips have been reset and will be shown again')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset All Tips'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Dismiss all tip IDs
                        state.dismissTip('settings-getting-started');
                        state.dismissTip('garden-select-plant');
                        state.dismissTip('plants-filter-tip');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All tips have been disabled')),
                        );
                      },
                      icon: const Icon(Icons.visibility_off),
                      label: const Text('Disable All Tips'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddBedDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController(text: 'Bed ${state.beds.length + 1}');
    final rowsController = TextEditingController(text: '8');
    final colsController = TextEditingController(text: '4');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: colsController,
              decoration: const InputDecoration(labelText: 'Columns'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.addBed(
                name: nameController.text,
                rows: int.tryParse(rowsController.text) ?? 8,
                cols: int.tryParse(colsController.text) ?? 4,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBedDialog(BuildContext context, AppState state, int index, GardenBed bed) {
    final nameController = TextEditingController(text: bed.name);
    final rowsController = TextEditingController(text: bed.rows.toString());
    final colsController = TextEditingController(text: bed.cols.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: colsController,
              decoration: const InputDecoration(labelText: 'Columns'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.updateBed(
                index,
                name: nameController.text,
                rows: int.tryParse(rowsController.text),
                cols: int.tryParse(colsController.text),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBed(BuildContext context, AppState state, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bed'),
        content: const Text('Are you sure you want to delete this bed? All plants and notes will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.removeBed(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
