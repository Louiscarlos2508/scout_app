import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/unit.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/member.dart';
import '../../../core/data/default_branches.dart';

/// Écran pour voir toutes les unités avec leurs branches et utilisateurs.
class UnitsOverviewScreen extends StatefulWidget {
  const UnitsOverviewScreen({super.key});

  @override
  State<UnitsOverviewScreen> createState() => _UnitsOverviewScreenState();
}

class _UnitsOverviewScreenState extends State<UnitsOverviewScreen> {
  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    // Charger les unités du groupe de l'admin
    if (adminProvider.units.isEmpty) {
      adminProvider.loadUnits();
    }
    if (adminProvider.users.isEmpty) {
      adminProvider.loadUsers();
    }
    
    // Charger tous les membres de toutes les branches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllMembers(memberProvider);
    });
  }

  Future<void> _loadAllMembers(MemberProvider memberProvider) async {
    // Charger les membres de toutes les branches
    final branches = DefaultBranches.allBranches;
    for (final branch in branches) {
      await memberProvider.loadMembersByBranch(branch.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vue d\'ensemble des unités'),
      ),
      body: Consumer3<AdminProvider, MemberProvider, AuthProvider>(
        builder: (context, adminProvider, memberProvider, authProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${adminProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.loadUnits();
                      adminProvider.loadUsers();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final currentUser = authProvider.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('Utilisateur non connecté'));
          }

          // Filtrer les unités du groupe de l'admin
          final units = adminProvider.units
              .where((u) => u.groupId == currentUser.unitId)
              .toList();

          if (units.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucune unité trouvée'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/admin/units/new'),
                    child: const Text('Créer une unité'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              final unitUsers = adminProvider.users
                  .where((u) => u.unitId == unit.id)
                  .toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    unit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${unit.branchIds.length} branche${unit.branchIds.length > 1 ? 's' : ''}, '
                    '${unitUsers.length} utilisateur${unitUsers.length > 1 ? 's' : ''}',
                  ),
                  children: [
                    // Branches de l'unité
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Branches:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: unit.branchIds.map((branchId) {
                              final branch = DefaultBranches.getBranchById(branchId);
                              final branchColor = branch?.color != null
                                  ? Color(int.parse(
                                      branch!.color.replaceFirst('#', 'FF', 0),
                                      radix: 16))
                                  : Colors.grey;
                              
                              // Améliorer le contraste pour la lisibilité
                              final textColor = _getContrastColor(branchColor);
                              
                              return Chip(
                                label: Text(
                                  branch?.name ?? branchId,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: branchColor,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Membres de l'unité par branche
                    ...unit.branchIds.map((branchId) {
                      final branch = DefaultBranches.getBranchById(branchId);
                      // Filtrer les membres de cette branche
                      // Note: Pour l'instant, on affiche tous les membres de la branche
                      // car Member n'a pas encore de champ unitId
                      final branchMembers = memberProvider.members
                          .where((m) => m.branchId == branchId)
                          .toList();
                      
                      if (branchMembers.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: branch?.color != null
                                        ? Color(int.parse(
                                            branch!.color.replaceFirst('#', 'FF', 0),
                                            radix: 16))
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${branch?.name ?? branchId} (${branchMembers.length} membre${branchMembers.length > 1 ? 's' : ''})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...branchMembers.map((member) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: branch?.color != null
                                        ? Color(int.parse(
                                            branch!.color.replaceFirst('#', 'FF', 0),
                                            radix: 16))
                                        : Colors.grey,
                                    child: Text(
                                      '${member.firstName[0]}${member.lastName[0]}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(member.fullName),
                                  subtitle: Text('${member.age} ans'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.chevron_right, size: 20),
                                    onPressed: () {
                                      context.push('/members/${member.id}');
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    // Utilisateurs de l'unité
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Utilisateurs:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  context.push('/admin/users/new?unitId=${unit.id}');
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Ajouter'),
                              ),
                            ],
                          ),
                          ...unitUsers.map((user) {
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                child: Text(
                                  '${user.firstName[0]}${user.lastName[0]}',
                                ),
                              ),
                              title: Text(user.fullName),
                              subtitle: Text(
                                user.role == UserRole.unitLeader
                                    ? 'Chef d\'unité'
                                    : user.role == UserRole.assistantLeader
                                        ? 'Assistant CU'
                                        : 'Admin',
                              ),
                              trailing: user.branchId != null
                                  ? Chip(
                                      label: Text(
                                        DefaultBranches.getBranchById(user.branchId!)
                                                ?.name ??
                                            user.branchId!,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    )
                                  : null,
                            );
                          }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push('/admin/units/${unit.id}/edit');
                            },
                            tooltip: 'Modifier',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteUnitDialog(context, unit, adminProvider);
                            },
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/units/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteUnitDialog(
    BuildContext context,
    Unit unit,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'unité'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'unité "${unit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.removeUnit(unit.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unité supprimée')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Calcule une couleur de texte avec un bon contraste pour une couleur de fond donnée.
  Color _getContrastColor(Color backgroundColor) {
    // Calculer la luminosité relative
    final luminance = backgroundColor.computeLuminance();
    // Si la couleur est claire, utiliser du texte sombre, sinon du texte clair
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

}
