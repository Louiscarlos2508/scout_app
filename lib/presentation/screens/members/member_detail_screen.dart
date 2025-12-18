import 'package:flutter/material.dart';

/// Écran affichant les détails d'un membre.
class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du membre'),
      ),
      body: const Center(
        child: Text('Détails du membre'),
      ),
    );
  }
}

