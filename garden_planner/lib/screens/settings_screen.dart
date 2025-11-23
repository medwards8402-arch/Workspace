import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/garden_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../domain/models/garden_bed.dart';
import '../models/plant.dart';
import '../widgets/tip.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final gardenProvider = context.watch<GardenProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
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
                  value: settingsProvider.zone,
                  isExpanded: true,
                  items: usdaZones.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (v) => settingsProvider.setZone(v!),
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
                      onPressed: () => _showAddBedDialog(context, gardenProvider),
                      tooltip: 'Add new bed',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...gardenProvider.beds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bed = entry.value;
                  final isFirst = index == 0;
                  final isLast = index == gardenProvider.beds.length - 1;
                  return Card(
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 32,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: isFirst ? null : () => gardenProvider.reorderBed(index, index - 1),
                              child: Icon(Icons.arrow_upward, size: 18, color: isFirst ? Colors.grey.shade300 : Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: isLast ? null : () => gardenProvider.reorderBed(index, index + 2),
                              child: Icon(Icons.arrow_downward, size: 18, color: isLast ? Colors.grey.shade300 : Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      title: Text(bed.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.backspace_outlined, size: 20, color: Colors.orange),
                            onPressed: () => _confirmClearBed(context, gardenProvider, index),
                            tooltip: 'Clear all plants',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditBedDialog(context, gardenProvider, index, bed),
                            tooltip: 'Edit bed',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _confirmDeleteBed(context, gardenProvider, index),
                            tooltip: 'Delete bed',
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
        
        // New Garden
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Garden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Start over with a fresh garden. This will clear all plants, beds, and settings.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Start New Garden?'),
                        content: const Text('This will clear all your plants, beds, notes, and reset all settings. This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await gardenProvider.resetToDefaults();
                              await settingsProvider.resetToDefaults();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Garden reset to defaults')),
                              );
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reset Garden'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.restart_alt, color: Colors.red),
                  label: const Text('Start New Garden', style: TextStyle(color: Colors.red)),
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
                      onPressed: () async {
                        await settingsProvider.resetAllTips();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All tips have been reset and will be shown again')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset All Tips'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // Dismiss all tip IDs
                        await settingsProvider.dismissTip('settings-getting-started');
                        await settingsProvider.dismissTip('garden-select-plant');
                        await settingsProvider.dismissTip('plants-filter-tip');
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

  void _showAddBedDialog(BuildContext context, GardenProvider gardenProvider) {
    final nameController = TextEditingController(text: 'Bed ${gardenProvider.beds.length + 1}');
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
            const SizedBox(height: 16),
            TextField(
              controller: rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
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
              gardenProvider.addBed(
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

  void _showEditBedDialog(BuildContext context, GardenProvider gardenProvider, int index, GardenBed bed) {
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
            const SizedBox(height: 16),
            TextField(
              controller: rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
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
              gardenProvider.updateBed(
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

  void _confirmDeleteBed(BuildContext context, GardenProvider gardenProvider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bed'),
        content: const Text('Are you sure you want to delete this bed? All plants and notes will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              gardenProvider.removeBed(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearBed(BuildContext context, GardenProvider gardenProvider, int index) {
    final bedName = gardenProvider.beds[index].name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Bed'),
        content: Text('Remove all plants from $bedName? This will clear all planted cells but keep the bed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              gardenProvider.clearBedCells(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$bedName cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
