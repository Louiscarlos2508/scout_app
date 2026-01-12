import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/member_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/member.dart';
import '../../../core/data/default_branches.dart';

/// Écran affichant la corbeille des membres supprimés (soft delete).
class DeletedMembersScreen extends StatefulWidget {
  const DeletedMembersScreen({super.key});

  @override
  State<DeletedMembersScreen> createState() => _DeletedMembersScreenState();
}

class _DeletedMembersScreenState extends State<DeletedMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemberProvider>(context, listen: false);
      if (provider.deletedMembers.isEmpty && !provider.isLoading) {
        provider.loadDeletedMembers();
      }
    });
  }

  Color _getBranchColor(String branchId) {
    final branch = DefaultBranches.getBranchById(branchId);
    if (branch != null) {
      final colorString = branch.color.replaceFirst('#', '');
      return Color(int.parse('FF$colorString', radix: 16));
    }
    return const Color(0xFF155DFC);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  void _showRestoreDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Restaurer le membre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous restaurer ${member.fullName} ?'),
            if (member.deletionReason != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Motif de suppression:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A7282),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member.deletionReason!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (member.deletedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Supprimé le: ${_formatDate(member.deletedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = Provider.of<MemberProvider>(context, listen: false);
              final success = await provider.restoreDeletedMember(member.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.fullName} a été restauré avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Erreur lors de la restauration'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corbeille'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<MemberProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.deletedMembers.isEmpty) {
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
                    onPressed: () => provider.loadDeletedMembers(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.deletedMembers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'La corbeille est vide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aucun membre supprimé',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDeletedMembers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.deletedMembers.length,
              itemBuilder: (context, index) {
                final member = provider.deletedMembers[index];
                final branchColor = _getBranchColor(member.branchId);
                final branch = DefaultBranches.getBranchById(member.branchId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: branchColor.withOpacity(0.2),
                      child: Text(
                        '${member.firstName[0]}${member.lastName[0]}',
                        style: TextStyle(
                          color: branchColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      member.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${member.age} ans • ${branch?.name ?? member.branchId}'),
                        if (member.deletedAt != null)
                          Text(
                            'Supprimé le ${_formatDate(member.deletedAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        if (member.deletionReason != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    member.deletionReason!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.restore, color: Colors.green),
                      onPressed: () => _showRestoreDialog(context, member),
                      tooltip: 'Restaurer',
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
