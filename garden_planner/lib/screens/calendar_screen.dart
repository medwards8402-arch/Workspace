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
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = tasks[i];
        return ListTile(
          leading: Text(t.icon, style: const TextStyle(fontSize: 24)),
          title: Text(t.label),
          subtitle: Text(_fmt(t.date)),
        );
      },
    );
  }

  String _fmt(DateTime d) => '${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month-1]} ${d.day}, ${d.year}';
}
