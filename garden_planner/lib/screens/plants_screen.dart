import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/plant_selection_provider.dart';
import '../presentation/providers/settings_provider.dart';
import 'plant_detail_screen.dart';
import '../widgets/tip.dart';
import '../widgets/plant_info_panel.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectionProvider = context.watch<PlantSelectionProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final filteredPlants = selectionProvider.getFilteredPlants();
    final selectedPlant = selectionProvider.selectedPlant;

    return Column(
      children: [
        // Plant grid
        Expanded(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
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
                        Icon(Icons.filter_list, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Filters (${filteredPlants.length} plants)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                        ),
                        if (selectionProvider.searchQuery.isNotEmpty || selectionProvider.filterType != 'all' || selectionProvider.filterLight != 'all')
                          TextButton.icon(
                            onPressed: () => selectionProvider.clearFilters(),
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Tip(
                      id: 'plants-filter-tip',
                      message: 'Use filters below to narrow plant selection by type, light requirements, or search by name.',
                    ),
                    const SizedBox(height: 8),
                    // Filters - First Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectionProvider.filterType,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                            onChanged: (v) => selectionProvider.setFilter(type: v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectionProvider.filterLight,
                            decoration: InputDecoration(
                              labelText: 'Light',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                            onChanged: (v) => selectionProvider.setFilter(light: v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Search Field - Second Row
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (v) => selectionProvider.setFilter(search: v),
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
                    final selected = selectionProvider.selectedPlantCode == plant.code;
                    return InkWell(
                      onTap: () {
                        try {
                          selectionProvider.selectPlant(plant.code);
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
            height: 280,
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
            child: PlantInfoPanel(plant: selectedPlant, zone: settingsProvider.zone),
          ),
      ],
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
