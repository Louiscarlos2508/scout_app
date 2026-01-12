import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../presentation/theme/app_colors.dart';

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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Délai minimum pour l'effet visuel
    await Future.delayed(const Duration(seconds: 1));

    // Vérifier l'état d'authentification
    // notifyListeners() déclenchera automatiquement le redirect du router
    // grâce à refreshListenable: authProvider
    await authProvider.checkAuthStatus();

    // Le redirect du router gérera automatiquement la navigation
    // Pas besoin de naviguer manuellement ici
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou nom de l'app
              Icon(
                Icons.flag,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'ScoutPresence',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
