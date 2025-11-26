import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../services/schedule_service.dart';
import '../presentation/providers/navigation_provider.dart';
import '../presentation/providers/library_navigation_provider.dart';

class PlantInfoPanel extends StatelessWidget {
  final Plant plant;
  final String zone;
  final Widget? notesWidget;

  const PlantInfoPanel({
    super.key,
    required this.plant,
    required this.zone,
    this.notesWidget,
  });

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(plant.icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plant.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    // Close the bottom sheet first
                    Navigator.pop(context);
                    // Set the plant in library navigation provider
                    final libraryNav = context.read<LibraryNavigationProvider>();
                    libraryNav.navigateToPlant(plant);
                    // Navigate to library tab
                    final navProvider = context.read<NavigationProvider>();
                    navProvider.setIndex(3); // Library is at index 3
                  },
                  tooltip: 'View in Library',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
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
                            const SizedBox(height: 3),
                            if (plant.startIndoorsWeeks > 0 && springSchedule.indoor != null) ...[
                              _InfoRow('Start Indoors:', formatDate(springSchedule.indoor)),
                              const SizedBox(height: 3),
                            ],
                            _InfoRow(
                              plant.startIndoorsWeeks > 0 ? 'Transplant:' : 'Direct Sow:',
                              formatDate(springSchedule.sow),
                            ),
                            const SizedBox(height: 3),
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
                              const SizedBox(height: 3),
                              if (plant.fallStartIndoorsWeeks > 0 && fallSchedule.indoor != null) ...[
                                _InfoRow('Start Indoors:', formatDate(fallSchedule.indoor)),
                                const SizedBox(height: 3),
                              ],
                              _InfoRow(
                                plant.fallStartIndoorsWeeks > 0 ? 'Transplant:' : 'Direct Sow:',
                                formatDate(fallSchedule.sow),
                              ),
                              const SizedBox(height: 3),
                              _InfoRow('Harvest:', formatDate(fallSchedule.harvest)),
                            ] else ...[
                              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 3),
                              _InfoRow(
                                'Spacing:',
                                (plant.cellsRequired ?? 1) > 1
                                    ? '1 / ${plant.cellsRequired} sq ft'
                                    : '${plant.sqftSpacing} / sq ft',
                              ),
                              const SizedBox(height: 3),
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
                  const SizedBox(height: 8),
                  
                  // Spacing info (if not already shown in right column)
                  if (fallSchedule != null) ...[
                    _InfoRow(
                      'Spacing:',
                      (plant.cellsRequired ?? 1) > 1
                          ? '1 / ${plant.cellsRequired} sq ft'
                          : '${plant.sqftSpacing} / sq ft',
                    ),
                    const SizedBox(height: 3),
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
                    const SizedBox(height: 6),
                  ],
                  
                  // Tips
                  if (plant.tips.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 6),
                    const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 3),
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
                  
                  // Notes widget (if provided)
                  if (notesWidget != null) ...[
                    const Divider(),
                    const SizedBox(height: 6),
                    notesWidget!,
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
