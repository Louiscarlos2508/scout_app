import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/member_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../core/data/default_branches.dart';

/// Écran du tableau de bord d'administration avec Lainisha.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Vérifier les droits d'accès
    if (authProvider.currentUser == null ||
        !authProvider.currentUser!.hasAdminAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
        ),
        body: const Center(
          child: Text('Vous n\'avez pas les droits d\'accès.'),
        ),
      );
    }

    final adminProvider = Provider.of<AdminProvider>(context);

    // Charger les utilisateurs, units et pending users si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (adminProvider.users.isEmpty && !adminProvider.isLoading) {
        adminProvider.loadUsers();
      }
      if (adminProvider.units.isEmpty) {
        adminProvider.loadUnits();
      }
      if (adminProvider.pendingUsers.isEmpty) {
        adminProvider.loadPendingUsers();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Header personnalisé avec statistiques
          _AdminHeader(
            adminProvider: adminProvider,
            authProvider: authProvider,
          ),
          // Contenu principal : Liste des utilisateurs
          Expanded(
            child: _UsersListView(
              adminProvider: adminProvider,
              authProvider: authProvider,
            ),
          ),
        ],
      ),
      // Menu d'actions rapides
      floatingActionButton: _QuickActionsMenu(
        adminProvider: adminProvider,
        memberProvider: Provider.of<MemberProvider>(context),
      ),
    );
  }
}

/// Header personnalisé avec statistiques et bouton de déconnexion.
class _AdminHeader extends StatelessWidget {
  final AdminProvider adminProvider;
  final AuthProvider authProvider;

  const _AdminHeader({
    required this.adminProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        final stats = _calculateStats(provider.users);

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tableau de bord',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Bouton de déconnexion
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Déconnexion',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Statistiques
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people,
                      label: 'Total',
                      value: stats['total']!.toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.admin_panel_settings,
                      label: 'Admins',
                      value: stats['admins']!.toString(),
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_outline,
                      label: 'Chefs',
                      value: stats['leaders']!.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.assistant,
                      label: 'Assistants',
                      value: stats['assistants']!.toString(),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _calculateStats(List<User> users) {
    int admins = 0;
    int leaders = 0;
    int assistants = 0;

    for (final user in users) {
      switch (user.role) {
        case UserRole.admin:
          admins++;
          break;
        case UserRole.unitLeader:
          leaders++;
          break;
        case UserRole.assistantLeader:
          assistants++;
          break;
      }
    }

    return {
      'total': users.length,
      'admins': admins,
      'leaders': leaders,
      'assistants': assistants,
    };
  }
}

/// Carte de statistique.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vue de liste des utilisateurs pour le dashboard admin.
class _UsersListView extends StatelessWidget {
  final AdminProvider adminProvider;
  final AuthProvider authProvider;

  const _UsersListView({
    required this.adminProvider,
    required this.authProvider,
  });

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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadUsers(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Aucun utilisateur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Créez votre premier utilisateur',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/users/new'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Créer un utilisateur'),
                ),
              ],
            ),
          );
        }

        // Filtrer l'admin connecté de la liste
        final currentUserId = authProvider.currentUser?.id;
        final filteredUsers = provider.users
            .where((user) => user.id != currentUserId)
            .toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Aucun autre utilisateur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous êtes le seul utilisateur',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/users/new'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Créer un utilisateur'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Builder(
                    builder: (context) {
                      // Récupérer le nom de l'unité depuis le provider
                      String unitName = user.unitId;
                      try {
                        final unit = provider.units.firstWhere(
                          (u) => u.id == user.unitId,
                        );
                        unitName = unit.name;
                      } catch (e) {
                        // Si l'unité n'est pas trouvée, garder l'ID
                      }

                      // Récupérer le nom de la branche
                      String branchName = user.branchId;
                      if (user.branchId.isNotEmpty) {
                        final branch = DefaultBranches.getBranchById(user.branchId);
                        branchName = branch?.name ?? user.branchId;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user.email}'),
                          Text('Rôle: ${_getRoleLabel(user.role)}'),
                          if (user.unitId.isNotEmpty)
                            Text('Unité: $unitName'),
                          if (user.branchId.isNotEmpty)
                            Text('Branche: $branchName'),
                        ],
                      );
                    },
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier le rôle'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => _showRoleDialog(context, user, provider),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.business, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier l\'unité et la branche'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => _showUnitBranchDialog(
                              context,
                              user,
                              provider,
                            ),
                          );
                        },
                      ),
                      if (!user.hasAdminAccess)
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _showDeleteDialog(context, user, provider),
                            );
                          },
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.unitLeader:
        return Colors.blue;
      case UserRole.assistantLeader:
        return Colors.green;
    }
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

  void _showUnitBranchDialog(
    BuildContext context,
    User user,
    AdminProvider provider,
  ) {
    String? selectedUnitId = user.unitId.isNotEmpty &&
            provider.units.any((u) => u.id == user.unitId)
        ? user.unitId
        : null;
    String? selectedBranchId = user.branchId.isNotEmpty ? user.branchId : null;
    List<String> availableBranchIds = [];

    // Charger les units si nécessaire
    if (provider.units.isEmpty) {
      provider.loadUnits();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Mettre à jour les branches disponibles selon l'unité sélectionnée
          if (selectedUnitId != null) {
            try {
              final unit = provider.units.firstWhere(
                (u) => u.id == selectedUnitId,
              );
              availableBranchIds = unit.branchIds;
              // Si la branche actuelle n'est pas dans les branches disponibles, la réinitialiser
              if (selectedBranchId != null &&
                  !availableBranchIds.contains(selectedBranchId)) {
                selectedBranchId = availableBranchIds.isNotEmpty
                    ? availableBranchIds.first
                    : null;
              }
            } catch (e) {
              availableBranchIds = [];
            }
          }

          return AlertDialog(
            title: Text('Modifier l\'unité et la branche de ${user.fullName}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisir l\'unité:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (provider.units.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Chargement des unités...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedUnitId != null &&
                              provider.units.any((u) => u.id == selectedUnitId)
                          ? selectedUnitId
                          : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: provider.units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit.id,
                          child: Text(unit.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUnitId = value;
                          selectedBranchId = null; // Réinitialiser la branche
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choisir la branche:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (selectedUnitId == null)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sélectionnez d\'abord une unité',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else if (availableBranchIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Aucune branche disponible pour cette unité',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedBranchId != null &&
                              availableBranchIds.contains(selectedBranchId)
                          ? selectedBranchId
                          : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: availableBranchIds.map((branchId) {
                        final branch = DefaultBranches.getBranchById(branchId);
                        return DropdownMenuItem<String>(
                          value: branchId,
                          child: Text(branch?.name ?? branchId),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedBranchId = value;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: (selectedUnitId != null && selectedBranchId != null)
                    ? () async {
                        Navigator.pop(context);
                        final success = await provider.updateUserUnitAndBranch(
                          user.id,
                          selectedUnitId!,
                          selectedBranchId!,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unité et branche mises à jour avec succès',
                              ),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur: ${provider.error ?? "Impossible de mettre à jour"}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Menu d'actions rapides pour l'admin.
class _QuickActionsMenu extends StatelessWidget {
  final AdminProvider adminProvider;
  final MemberProvider memberProvider;

  const _QuickActionsMenu({
    required this.adminProvider,
    required this.memberProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'pending',
          onPressed: () {
            adminProvider.loadPendingUsers();
            context.push('/admin/pending-users');
          },
          child: Stack(
            children: [
              const Icon(Icons.pending_actions),
              if (adminProvider.pendingUsers.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${adminProvider.pendingUsers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: 'Demandes en attente',
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'units',
          onPressed: () => context.push('/admin/units/overview'),
          child: const Icon(Icons.business),
          tooltip: 'Vue d\'ensemble des unités',
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'new_unit',
          onPressed: () => context.push('/admin/units/new'),
          child: const Icon(Icons.add_business),
          tooltip: 'Créer une unité',
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'users',
          onPressed: () => context.push('/admin/users/new'),
          child: const Icon(Icons.person_add),
          tooltip: 'Créer un utilisateur',
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'deleted',
          onPressed: () {
            memberProvider.loadDeletedMembers();
            context.push('/admin/deleted-members');
          },
          child: Consumer<MemberProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  const Icon(Icons.delete_outline),
                  if (provider.deletedMembers.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.deletedMembers.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          tooltip: 'Corbeille',
        ),
      ],
    );
  }
}
