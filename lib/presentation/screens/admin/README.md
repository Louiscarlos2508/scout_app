# Module d'Administration

Ce module fournit les fonctionnalités d'administration pour le projet ScoutPresence.

## Structure

- `admin_dashboard_screen.dart` : Tableau de bord principal avec statistiques
- `user_management_screen.dart` : Gestion complète des utilisateurs

## Fonctionnalités

### Tableau de bord
- Vue d'ensemble des statistiques (total utilisateurs, admins, chefs, assistants)
- Accès rapide à la gestion des utilisateurs

### Gestion des utilisateurs
- Liste de tous les utilisateurs
- Modification des rôles
- Suppression d'utilisateurs

## Accès

Seuls les utilisateurs avec le rôle `UserRole.admin` peuvent accéder à ce module.

## Utilisation

```dart
// Vérifier les droits d'accès
if (user.hasAdminAccess) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AdminDashboardScreen(),
    ),
  );
}
```

## Provider

Le module utilise `AdminProvider` pour gérer l'état :
- `loadUsers()` : Charge tous les utilisateurs
- `changeUserRole()` : Modifie le rôle d'un utilisateur
- `removeUser()` : Supprime un utilisateur

## Package utilisé

Le projet utilise [Lainisha](https://pub.dev/packages/lainisha), un framework admin cross-platform pour Flutter avec support Material 3.
