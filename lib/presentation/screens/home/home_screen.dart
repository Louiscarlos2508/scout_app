import 'package:flutter/material.dart';

/// Écran d'accueil principal de l'application.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScoutPresence'),
      ),
      body: const Center(
        child: Text('Écran d\'accueil'),
      ),
    );
  }
}

