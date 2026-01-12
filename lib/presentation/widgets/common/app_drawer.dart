import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart';

/// Drawer de navigation réutilisable pour toute l'application.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Utilisateur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user != null)
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              // Si l'utilisateur est admin, ne pas afficher les fonctionnalités normales
              if (user?.hasAdminAccess ?? false) ...[
                _buildDrawerItem(
                  context,
                  'Tableau de bord Admin',
                  Icons.dashboard,
                  () => context.go('/admin'),
                ),
              ] else ...[
                _buildDrawerItem(
                  context,
                  'Accueil',
                  Icons.home,
                  () => context.go('/home'),
                ),
                _buildDrawerItem(
                  context,
                  'Membres',
                  Icons.people,
                  () => context.go('/members'),
                ),
                _buildDrawerItem(
                  context,
                  'Présences',
                  Icons.check_circle,
                  () => context.go('/attendance'),
                ),
              ],
              // Menu admin conditionnel
              if (user?.hasAdminAccess ?? false) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Administration',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  'Tableau de bord',
                  Icons.dashboard,
                  () => context.go('/admin'),
                ),
                _buildDrawerItem(
                  context,
                  'Gestion utilisateurs',
                  Icons.admin_panel_settings,
                  () => context.go('/admin/users'),
                ),
              ],
              const Divider(),
              _buildDrawerItem(
                context,
                'Déconnexion',
                Icons.logout,
                () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                textColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
