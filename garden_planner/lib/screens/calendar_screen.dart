import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tasks = state.calendarTasks();
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$monthName ${firstDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Tasks for this month
            ...monthTasks.map((t) => Card(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Text(t.icon, style: const TextStyle(fontSize: 20)),
                title: Text(t.label, style: const TextStyle(fontSize: 14)),
                subtitle: Text(_fmt(t.date), style: const TextStyle(fontSize: 12)),
              ),
            )),
          ],
        );
      },
    );
  }

  String _fmt(DateTime d) => '${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month-1]} ${d.day}, ${d.year}';
}
