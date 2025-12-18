import 'package:flutter/material.dart';

/// Écran affichant la liste des membres d'une branche.
class MembersListScreen extends StatelessWidget {
  final String branchId;

  const MembersListScreen({
    super.key,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membres'),
      ),
      body: const Center(
        child: Text('Liste des membres'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigation vers le formulaire de création
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

