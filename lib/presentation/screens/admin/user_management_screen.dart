import 'package:flutter/material.dart';
import 'package:lainisha/lainisha.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/user.dart';
import '../../providers/admin_provider.dart';
import 'lainisha_data_provider.dart';

/// Écran de gestion des utilisateurs avec Lainisha ListGuesser.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${provider.error}'),
                ElevatedButton(
                  onPressed: () => provider.loadUsers(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return const Center(
            child: Text('Aucun utilisateur trouvé'),
          );
        }

        // Utiliser ListGuesser de Lainisha pour afficher la liste
        final dataProvider = UserLainishaDataProvider(provider);
        
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: dataProvider.fetchList<Map<String, dynamic>>('users'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erreur: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () => provider.loadUsers(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(
                child: Text('Aucun utilisateur trouvé'),
              );
            }

            // Utiliser ListGuesser pour afficher la liste automatiquement
            return ListGuesser(
              data: data,
            );
          },
        );
      },
    );
  }


  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.unitLeader:
        return 'Chef d\'Unité';
      case UserRole.assistantLeader:
        return 'Assistant CU';
    }
  }


  void _showRoleDialog(
    BuildContext context,
    User user,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<UserRole>(
              title: Text(_getRoleLabel(role)),
              value: role,
              groupValue: user.role,
              onChanged: (value) {
                if (value != null) {
                  provider.changeUserRole(user.id, value).then((success) {
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rôle mis à jour avec succès'),
                        ),
                      );
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    User user,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${user.fullName} ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.removeUser(user.id).then((success) {
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur supprimé avec succès'),
                    ),
                  );
                }
              });
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
