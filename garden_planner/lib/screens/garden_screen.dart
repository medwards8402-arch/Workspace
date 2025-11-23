import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Zone:'),
              DropdownButton<String>(
                value: state.zone,
                items: usdaZones.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (v) => state.setZone(v!),
              ),
              if (state.selectedPlant != null)
                Chip(label: Text(state.selectedPlant!.name), avatar: Text(state.selectedPlant!.icon))
              else
                const Text('Select a plant from Plants tab')
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: state.beds.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, bedIndex) {
              final bed = state.beds[bedIndex];
              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: bed.cols,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: bed.rows * bed.cols,
                    itemBuilder: (context, idx) {
                      final cell = bed.cells[idx];
                      final plant = cell.plantCode == null ? null : plants.firstWhere((p) => p.code == cell.plantCode);
                      return GestureDetector(
                        onTap: () {
                          if (state.selectedPlantCode != null && cell.plantCode == null) {
                            state.placeSelectedPlant(bedIndex, idx);
                          } else if (plant != null) {
                            _showCellSheet(context, state, bedIndex, idx, plant);
                          }
                        },
                        onLongPress: () {
                          _editNoteDialog(context, state, bedIndex, idx, plant);
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                color: plant == null ? Colors.white : _hexColor(plant.color).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(plant?.icon ?? '', style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            if (cell.note != null && cell.note!.isNotEmpty)
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Icon(Icons.note, size: 14, color: Colors.brown.shade700),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  void _showCellSheet(BuildContext context, AppState state, int bedIndex, int cellIndex, Plant plant) {
    final cell = state.beds[bedIndex].cells[cellIndex];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final noteController = TextEditingController(text: cell.note ?? '');
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Text(plant.icon, style: const TextStyle(fontSize: 28)), const SizedBox(width: 8), Expanded(child: Text(plant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))]),
              const SizedBox(height: 12),
              if (cell.note != null && cell.note!.isNotEmpty)
                Text(cell.note!, style: const TextStyle(fontSize: 14))
              else
                const Text('No note yet.'),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final v = noteController.text.trim();
                      state.updateCellNote(bedIndex, cellIndex, v.isEmpty ? null : v);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      state.clearCell(bedIndex, cellIndex);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _editNoteDialog(BuildContext context, AppState state, int bedIndex, int cellIndex, Plant? plant) {
    final cell = state.beds[bedIndex].cells[cellIndex];
    final controller = TextEditingController(text: cell.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cell Note ${plant != null ? '(${plant.name})' : ''}'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter note'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              state.updateCellNote(bedIndex, cellIndex, v.isEmpty ? null : v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
