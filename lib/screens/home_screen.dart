import 'package:flutter/material.dart';

import '../models/smoke_item.dart';
import 'smoke_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RauchSim')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Was möchtest du „rauchen“?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Wähle etwas aus und mach dann ein Sauggeräusch: Die Glut auf dem Display brennt bei jedem Zug weiter.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          for (final SmokeItem item in SmokeItem.all) _ItemCard(item: item),
          const SizedBox(height: 24),
          Text(
            'Nur eine Simulation. Es wird nichts aufgenommen oder gespeichert - ausgewertet wird nur der aktuelle Lautstärkepegel.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final SmokeItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.bodyColor.withValues(alpha: 0.15),
          child: Text(item.icon, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(item.label),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SmokeScreen(item: item)),
        ),
      ),
    );
  }
}
