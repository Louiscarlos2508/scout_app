import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/user.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

/// Widget sélecteur de branche avec filtrage selon le rôle utilisateur.
class BranchSelector extends StatelessWidget {
  final String? selectedBranchId;
  final ValueChanged<String?> onBranchChanged;
  final bool showLabel;

  const BranchSelector({
    super.key,
    this.selectedBranchId,
    required this.onBranchChanged,
    this.showLabel = true,
  });

  Color _getBranchColor(String branchId) {
    switch (branchId) {
      case 'louveteaux':
        return AppColors.louveteaux;
      case 'eclaireurs':
        return AppColors.eclaireurs;
      case 'sinikie':
        return AppColors.sinikie;
      case 'routiers':
        return AppColors.routiers;
      default:
        return AppColors.primary;
    }
  }

  List<Branch> _getAvailableBranches(
    List<Branch> allBranches,
    User? currentUser,
  ) {
    if (currentUser == null) {
      return allBranches;
    }

    // L'admin et le chef d'unité voient toutes les branches
    if (currentUser.role == UserRole.admin ||
        currentUser.role == UserRole.unitLeader) {
      return allBranches;
    }

    // Le chef assistant ne voit que sa branche
    if (currentUser.role == UserRole.assistantLeader &&
        currentUser.branchId != null) {
      return allBranches
          .where((b) => b.id == currentUser.branchId)
          .toList();
    }

    return allBranches;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BranchProvider>(
      builder: (context, branchProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Charger les branches si nécessaire
        if (branchProvider.branches.isEmpty && !branchProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            branchProvider.loadAllBranches();
          });
        }

        final availableBranches = _getAvailableBranches(
          branchProvider.branches,
          authProvider.currentUser,
        );

        // Si une seule branche disponible, la sélectionner automatiquement
        if (availableBranches.length == 1 && selectedBranchId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onBranchChanged(availableBranches.first.id);
          });
        }

        if (branchProvider.isLoading) {
          return const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (availableBranches.isEmpty) {
          return const SizedBox.shrink();
        }

        // Si une seule branche, afficher juste le nom (pas de dropdown)
        if (availableBranches.length == 1) {
          final branch = availableBranches.first;
          final branchColor = _getBranchColor(branch.id);
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: branchColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: branchColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: branchColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  branch.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: branchColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          );
        }

        // Plusieurs branches : afficher un dropdown
        return DropdownButtonFormField<String>(
          value: selectedBranchId ?? availableBranches.first.id,
          decoration: InputDecoration(
            labelText: showLabel ? 'Branche' : null,
            prefixIcon: const Icon(Icons.group),
            filled: true,
          ),
          items: availableBranches.map((branch) {
            final branchColor = _getBranchColor(branch.id);
            return DropdownMenuItem<String>(
              value: branch.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: branchColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${branch.name} (${branch.ageRange})'),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => onBranchChanged(value),
        );
      },
    );
  }
}
