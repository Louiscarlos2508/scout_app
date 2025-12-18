import 'package:flutter/material.dart';

/// Écran de création d'une nouvelle session de présence.
class CreateSessionScreen extends StatelessWidget {
  final String branchId;

  const CreateSessionScreen({
    super.key,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle session'),
      ),
      body: const Center(
        child: Text('Créer une session'),
      ),
    );
  }
}

