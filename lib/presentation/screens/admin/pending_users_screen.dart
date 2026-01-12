import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/unit.dart' as entity;
import '../../../core/data/default_branches.dart';

/// Écran pour voir et valider les utilisateurs en attente.
class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Utiliser un post-frame callback pour éviter setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      // Toujours charger les units et pending users pour avoir les données à jour
      adminProvider.loadUnits();
      adminProvider.loadPendingUsers();
    });
  }

  void _showApproveDialog(User user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    UserRole? selectedRole = UserRole.unitLeader;
    
    // Vérifier que l'unité de l'utilisateur existe dans la liste des units
    String? selectedUnitId;
    if (user.unitId.isNotEmpty && 
        adminProvider.units.any((u) => u.id == user.unitId)) {
      selectedUnitId = user.unitId;
    }
    
    String? selectedBranchId = user.branchId.isEmpty ? null : user.branchId;
    List<String> availableBranchIds = [];

    // Charger les units si nécessaire
    if (adminProvider.units.isEmpty) {
      adminProvider.loadUnits();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Mettre à jour les branches disponibles selon l'unité sélectionnée
          if (selectedUnitId != null) {
            try {
              final unit = adminProvider.units.firstWhere(
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
            title: const Text('Valider l\'utilisateur'),
            content: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.firstName} ${user.lastName}'),
                Text('Email: ${user.email}'),
                Text('Téléphone: ${user.phoneNumber}'),
                const SizedBox(height: 16),
                const Text(
                  'Choisir le rôle:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioListTile<UserRole>(
                  title: const Text('Chef d\'unité'),
                  value: UserRole.unitLeader,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value;
                    });
                  },
                ),
                RadioListTile<UserRole>(
                  title: const Text('Assistant CU'),
                  value: UserRole.assistantLeader,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choisir l\'unité:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (adminProvider.units.isEmpty)
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
                              adminProvider.units.any((u) => u.id == selectedUnitId)
                          ? selectedUnitId
                          : null, // Si la valeur n'existe pas, utiliser null
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: adminProvider.units.map((unit) {
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
                          : null, // Si la valeur n'existe pas, utiliser null
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
                onPressed: (selectedRole != null &&
                        selectedUnitId != null &&
                        selectedBranchId != null)
                    ? () async {
                    Navigator.pop(context);
                    final adminProvider =
                        Provider.of<AdminProvider>(context, listen: false);
                        final success = await adminProvider.approvePendingUser(
                          user.id,
                          selectedRole!,
                          unitId: selectedUnitId,
                          branchId: selectedBranchId,
                        );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${user.firstName} ${user.lastName} a été validé comme ${selectedRole == UserRole.unitLeader ? "Chef d\'unité" : "Assistant CU"}',
                          ),
                        ),
                      );
                    }
                  }
                    : null,
                child: const Text('Valider'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes en attente'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pendingUsers.isEmpty) {
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
                    onPressed: () => provider.loadPendingUsers(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Filtrer les admins au cas où (double sécurité)
          // Les admins ne doivent jamais apparaître dans la liste des demandes en attente
          final filteredPendingUsers = provider.pendingUsers
              .where((user) => !user.hasAdminAccess)
              .toList();

          if (filteredPendingUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune demande en attente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tous les utilisateurs ont été validés',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPendingUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPendingUsers.length,
              itemBuilder: (context, index) {
                final user = filteredPendingUsers[index];
                final branch = DefaultBranches.getBranchById(user.branchId);
                // Gérer le cas où l'unité n'est pas trouvée (peut arriver si les units ne sont pas encore chargées)
                entity.Unit unit;
                try {
                  unit = provider.units.firstWhere(
                  (u) => u.id == user.unitId,
                  );
                } catch (e) {
                  // Si l'unité n'est pas trouvée, créer une unité par défaut
                  unit = entity.Unit(
                    id: user.unitId,
                    name: 'Unité non trouvée',
                    groupId: '',
                    branchIds: [],
                );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF314158),
                      child: Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${user.email}'),
                        Text('Téléphone: ${user.phoneNumber}'),
                        Text('Unité: ${unit.name}'),
                        Text('Branche: ${branch?.name ?? user.branchId}'),
                        Text(
                          'Date de naissance: ${user.dateOfBirth.day}/${user.dateOfBirth.month}/${user.dateOfBirth.year}',
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showApproveDialog(user),
                      child: const Text('Valider'),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
