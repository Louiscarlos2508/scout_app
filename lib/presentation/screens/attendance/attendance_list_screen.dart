import 'package:flutter/material.dart';

/// Écran affichant la liste des sessions de présence.
class AttendanceListScreen extends StatelessWidget {
  final String branchId;

  const AttendanceListScreen({
    super.key,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Présences'),
      ),
      body: const Center(
        child: Text('Liste des sessions de présence'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigation vers la création de session
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

