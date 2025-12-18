import 'package:flutter/material.dart';

/// Écran de démarrage (splash screen).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Vérifier l'état d'authentification et rediriger
    Future.delayed(const Duration(seconds: 2), () {
      // TODO: Navigation vers login ou home selon l'état d'auth
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

