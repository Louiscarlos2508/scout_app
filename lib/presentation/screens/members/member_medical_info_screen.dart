import 'package:flutter/material.dart';

/// Écran affichant les informations médicales d'un membre.
class MemberMedicalInfoScreen extends StatelessWidget {
  final String memberId;

  const MemberMedicalInfoScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations médicales'),
      ),
      body: const Center(
        child: Text('Informations médicales'),
      ),
    );
  }
}

