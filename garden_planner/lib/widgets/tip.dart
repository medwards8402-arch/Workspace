import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/settings_provider.dart';

class Tip extends StatelessWidget {
  final String id;
  final String message;

  const Tip({super.key, required this.id, required this.message});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    if (settingsProvider.isTipDismissed(id)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
          TextButton(
            onPressed: () => settingsProvider.dismissTip(id),
            child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
