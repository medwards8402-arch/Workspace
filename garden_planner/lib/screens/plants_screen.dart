import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';
import '../services/schedule_service.dart';
import 'plant_detail_screen.dart';
import '../widgets/tip.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allPlants = state.allPlants;
    
    // Apply filters
    final filteredPlants = allPlants.where((plant) {
      final typeMatch = state.plantFilterType == 'all' || plant.type == state.plantFilterType;
      final lightMatch = state.plantFilterLight == 'all' || plant.lightLevel == state.plantFilterLight;
      final searchMatch = state.plantSearchQuery.isEmpty || 
        plant.name.toLowerCase().contains(state.plantSearchQuery.toLowerCase());
      return typeMatch && lightMatch && searchMatch;
    }).toList();
    
    final selectedPlant = state.selectedPlantCode != null
        ? allPlants.firstWhere((p) => p.code == state.selectedPlantCode, orElse: () => allPlants.first)
        : null;

    return Column(
      children: [
        // Plant grid
        Expanded(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filters (${filteredPlants.length} plants)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                        ),
                        if (state.plantSearchQuery.isNotEmpty || state.plantFilterType != 'all' || state.plantFilterLight != 'all')
                          TextButton.icon(
                            onPressed: () => state.setPlantFilter(type: 'all', light: 'all', search: ''),
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Tip(
                      id: 'plants-filter-tip',
                      message: 'Use filters below to narrow plant selection by type, light requirements, or search by name.',
                    ),
                    const SizedBox(height: 12),
                    // Filters - First Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.plantFilterType,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Types')),
                              DropdownMenuItem(value: 'vegetable', child: Text('Vegetable')),
                              DropdownMenuItem(value: 'fruit', child: Text('Fruit')),
                              DropdownMenuItem(value: 'herb', child: Text('Herb')),
                            ],
                            onChanged: (v) => state.setPlantFilter(type: v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.plantFilterLight,
                            decoration: InputDecoration(
                              labelText: 'Light',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Light')),
                              DropdownMenuItem(value: 'high', child: Text('High')),
                              DropdownMenuItem(value: 'low', child: Text('Low')),
                            ],
                            onChanged: (v) => state.setPlantFilter(light: v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search Field - Second Row
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (v) => state.setPlantFilter(search: v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredPlants.isEmpty
                    ? const Center(child: Text('No plants match your filters'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: filteredPlants.length,
                  itemBuilder: (context, i) {
                    final plant = filteredPlants[i];
                    final selected = state.selectedPlantCode == plant.code;
                    return InkWell(
                      onTap: () {
                        try {
                          state.selectPlant(plant.code);
                        } catch (e) {
                          debugPrint('Error selecting plant: $e');
                        }
                      },
                      onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant))),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? Colors.green : Colors.grey.shade300, width: selected ? 2 : 1),
                          color: _hexColor(plant.color).withOpacity(0.15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(plant.icon, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 2),
                              Flexible(
                                child: Text(
                                  plant.name, 
                                  textAlign: TextAlign.center, 
                                  maxLines: 2, 
                                  overflow: TextOverflow.ellipsis, 
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Plant info panel at bottom
        if (selectedPlant != null)
          Container(
            height: 240,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _PlantInfoPanel(plant: selectedPlant, zone: state.zone),
          ),
      ],
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class _PlantInfoPanel extends StatelessWidget {
  final Plant plant;
  final String zone;

  const _PlantInfoPanel({required this.plant, required this.zone});

  @override
  Widget build(BuildContext context) {
    try {
      final springSchedule = ScheduleService.computeSpringSchedule(plant, zone);
      final fallSchedule = plant.supportsFall ? ScheduleService.computeFallSchedule(plant, zone) : null;
      
      String formatDate(DateTime? date) {
        if (date == null) return 'N/A';
        return '${_monthName(date.month)} ${date.day}, ${date.year}';
      }

      return Column(
        children: [
          // Header with plant icon and name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _hexColor(plant.color).withOpacity(0.7),
                  _hexColor(plant.color),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(plant.icon, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plant.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two-column layout for info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Left column - Spring schedule
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spring:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      if (plant.startIndoorsWeeks > 0 && springSchedule.indoor != null) ...[
                        _InfoRow('Start Indoors:', formatDate(springSchedule.indoor)),
                        const SizedBox(height: 4),
                      ],
                      _InfoRow(
                        plant.startIndoorsWeeks > 0 ? 'Transplant:' : 'Direct Sow:',
                        formatDate(springSchedule.sow),
                      ),
                      const SizedBox(height: 4),
                      _InfoRow('Harvest:', formatDate(springSchedule.harvest)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column - Fall schedule or spacing info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fallSchedule != null) ...[
                        const Text('Fall:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        if (plant.fallStartIndoorsWeeks > 0 && fallSchedule.indoor != null) ...[
                          _InfoRow('Start Indoors:', formatDate(fallSchedule.indoor)),
                          const SizedBox(height: 4),
                        ],
                        _InfoRow(
                          plant.fallStartIndoorsWeeks > 0 ? 'Transplant:' : 'Direct Sow:',
                          formatDate(fallSchedule.sow),
                        ),
                        const SizedBox(height: 4),
                        _InfoRow('Harvest:', formatDate(fallSchedule.harvest)),
                      ] else ...[
                        const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        _InfoRow(
                          'Spacing:',
                          (plant.cellsRequired ?? 1) > 1
                              ? '1 / ${plant.cellsRequired} sq ft'
                              : '${plant.sqftSpacing} / sq ft',
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Light: ', style: TextStyle(fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: plant.lightLevel == 'high' ? Colors.orange : Colors.blueGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(plant.lightLevel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Spacing info (if not already shown in right column)
            if (fallSchedule != null) ...[
              _InfoRow(
                'Spacing:',
                (plant.cellsRequired ?? 1) > 1
                    ? '1 / ${plant.cellsRequired} sq ft'
                    : '${plant.sqftSpacing} / sq ft',
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Light: ', style: TextStyle(fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: plant.lightLevel == 'high' ? Colors.orange : Colors.blueGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(plant.lightLevel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Tips
            if (plant.tips.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              ...plant.tips.take(3).map((tip) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 12)),
                        Expanded(child: Text(tip, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    ),
  ],
);
    } catch (e) {
      debugPrint('Error building plant info panel: $e');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Error loading plant info', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(e.toString(), style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
