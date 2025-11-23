import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';
import 'plant_detail_screen.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.allPlants;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Plants (${list.length})', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final plant = list[i];
              final selected = state.selectedPlantCode == plant.code;
              return InkWell(
                onTap: () => state.selectPlant(plant.code),
                onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlantDetailScreen(plant: plant))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.green : Colors.grey.shade300, width: selected ? 2 : 1),
                    color: _hexColor(plant.color).withOpacity(0.15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(plant.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(plant.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${plant.sqftSpacing}/sqft', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                        Text(plant.lightLevel, style: TextStyle(fontSize: 10, color: plant.lightLevel == 'high' ? Colors.orange : Colors.blueGrey)),
                      ],
                    ),
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
}
