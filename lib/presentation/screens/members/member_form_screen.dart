import 'package:flutter/material.dart';

/// Écran de formulaire pour créer/modifier un membre.
class MemberFormScreen extends StatelessWidget {
  final String? memberId; // null si création, défini si modification

  const MemberFormScreen({
    super.key,
    this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memberId == null ? 'Nouveau membre' : 'Modifier membre'),
      ),
      body: const Center(
        child: Text('Formulaire membre'),
      ),
    );
  }
}

