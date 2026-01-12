import 'package:flutter/material.dart';
import 'app_drawer.dart';

/// Scaffold personnalisé avec drawer automatique pour toute l'application.
/// 
/// Ce widget encapsule le Scaffold standard avec le drawer de navigation,
/// évitant la duplication de code et garantissant la cohérence.
class AppScaffold extends StatelessWidget {
  /// Titre affiché dans l'AppBar.
  final String? title;

  /// Widget personnalisé pour l'AppBar (si null, une AppBar standard est créée).
  final PreferredSizeWidget? appBar;

  /// Actions à afficher dans l'AppBar.
  final List<Widget>? actions;

  /// Corps de l'écran.
  final Widget body;

  /// Bouton d'action flottant.
  final Widget? floatingActionButton;

  /// Position du bouton d'action flottant.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Indique si le drawer doit être affiché (par défaut: true).
  /// Utile pour les écrans comme LoginScreen qui ne doivent pas avoir de drawer.
  final bool showDrawer;

  /// Indique si le drawer peut être ouvert (par défaut: true).
  final bool drawerEnableOpenDragGesture;

  const AppScaffold({
    super.key,
    this.title,
    this.appBar,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showDrawer = true,
    this.drawerEnableOpenDragGesture = true,
  }) : assert(
          title == null || appBar == null,
          'Cannot provide both title and appBar',
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  actions: actions,
                )
              : null),
      drawer: showDrawer ? const AppDrawer() : null,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
