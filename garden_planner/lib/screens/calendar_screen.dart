import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/garden_provider.dart';
import '../presentation/providers/settings_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gardenProvider = context.watch<GardenProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final tasks = gardenProvider.calendarTasks(settingsProvider.zone);
    if (tasks.isEmpty) {
      return const Center(child: Text('Place plants in garden to see tasks.'));
    }
    
    // Group tasks by month
    final groupedTasks = <String, List<dynamic>>{};
    for (final task in tasks) {
      final monthKey = '${task.date.year}-${task.date.month.toString().padLeft(2, '0')}';
      groupedTasks.putIfAbsent(monthKey, () => []).add(task);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedTasks.length,
      itemBuilder: (context, groupIndex) {
        final monthKey = groupedTasks.keys.elementAt(groupIndex);
        final monthTasks = groupedTasks[monthKey]!;
        final firstDate = monthTasks[0].date;
        final monthName = ['January','February','March','April','May','June','July','August','September','October','November','December'][firstDate.month-1];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              margin: const EdgeInsets.only(top: 4, bottom: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$monthName ${firstDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Tasks for this month
            ...monthTasks.map((t) => Card(
              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                leading: Text(t.icon, style: const TextStyle(fontSize: 16)),
                title: Text(t.label, style: const TextStyle(fontSize: 12)),
                subtitle: Text(_fmt(t.date), style: const TextStyle(fontSize: 10)),
              ),
            )),
          ],
        );
      },
    );
  }

  String _fmt(DateTime d) => '${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month-1]} ${d.day}, ${d.year}';
}
