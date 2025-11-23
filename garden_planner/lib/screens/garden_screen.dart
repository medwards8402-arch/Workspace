import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';
import '../services/schedule_service.dart';
import '../widgets/tip.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.green.shade50,
          child: Column(
            children: [
              if (state.selectedPlant != null)
                Row(
                  children: [
                    Text(state.selectedPlant!.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Planting: ${state.selectedPlant!.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => state.selectPlant(null),
                      child: const Text('Clear'),
                    ),
                  ],
                )
              else
                const Tip(
                  id: 'garden-select-plant',
                  message: 'Go to Plants tab to select what to plant, then tap cells to place plants in your beds.',
                ),
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
                child: Column(
                  children: [
                    // Bed name header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bed.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${bed.rows}×${bed.cols}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Grid
                    Expanded(
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
                                      child: state.showPlantNames && plant != null
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(plant.icon, style: const TextStyle(fontSize: 16)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  plant.name,
                                                  style: const TextStyle(fontSize: 8),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            )
                                          : Text(plant?.icon ?? '', style: const TextStyle(fontSize: 20)),
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
                    ),
                  ],
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
    final springSchedule = ScheduleService.computeSpringSchedule(plant, state.zone);
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final noteController = TextEditingController(text: cell.note ?? '');
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hexColor(plant.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(plant.icon, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plant.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Plant Info
                  Text('Plant Information', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildInfoRow('Direct Sow:', springSchedule.sow != null 
                    ? '${_monthName(springSchedule.sow!.month)} ${springSchedule.sow!.day}'
                    : 'N/A'),
                  _buildInfoRow('Harvest:', springSchedule.harvest != null
                    ? '${_monthName(springSchedule.harvest!.month)} ${springSchedule.harvest!.day}'
                    : 'N/A'),
                  _buildInfoRow('Spacing:', (plant.cellsRequired ?? 1) > 1
                      ? '1 plant / ${plant.cellsRequired} sq ft'
                      : '${plant.sqftSpacing} plant${plant.sqftSpacing > 1 ? "s" : ""} / sq ft'),
                  Row(
                    children: [
                      const Text('Light: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: plant.lightLevel == 'high' ? Colors.orange : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(plant.lightLevel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Cell Note
                  Text('Cell Note', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add a note for this cell...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final v = noteController.text.trim();
                          state.updateCellNote(bedIndex, cellIndex, v.isEmpty ? null : v);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Note'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          state.clearCell(bedIndex, cellIndex);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Remove Plant', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
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
