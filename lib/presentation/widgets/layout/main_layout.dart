import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../common/app_drawer.dart';

/// Layout principal avec drawer persistant pour toutes les pages authentifiées.
/// 
/// Ce widget maintient le Scaffold et le drawer constants, seul le body change
/// selon la route. C'est la meilleure approche pour une navigation fluide.
class MainLayout extends StatelessWidget {
  /// Le contenu de la page actuelle (affiché dans le body).
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Récupérer le titre depuis la route actuelle
    final routeName = GoRouterState.of(context).uri.path;
    final title = _getTitleForRoute(routeName);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          // Rediriger vers l'accueil au lieu de quitter l'application
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: const AppDrawer(),
        // Si l'enfant est un Scaffold (pour FAB), on l'affiche tel quel
        // Sinon, on l'affiche dans le body
        body: child,
      ),
    );
  }

  /// Retourne le titre approprié selon la route.
  String _getTitleForRoute(String path) {
    switch (path) {
      case '/home':
        return 'ScoutPresence';
      case '/members':
        return 'Membres';
      case '/attendance':
        return 'Présences';
      case '/admin':
        return 'Administration';
      case '/admin/users':
        return 'Gestion utilisateurs';
      default:
        return 'ScoutPresence';
    }
  }
}
