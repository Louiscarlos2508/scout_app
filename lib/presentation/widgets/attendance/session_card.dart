import 'package:flutter/material.dart';

/// Carte affichant les informations d'une session de présence.
class SessionCard extends StatelessWidget {
  final String date;
  final String type;
  final int presentCount;
  final int totalCount;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.date,
    required this.type,
    required this.presentCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(date),
        subtitle: Text('$type - $presentCount/$totalCount présents'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

