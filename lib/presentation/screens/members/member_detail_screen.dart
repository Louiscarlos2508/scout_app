import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/parent_contact.dart';
import '../../../domain/entities/phone_number.dart';
import '../../providers/member_provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_colors.dart';
import '../../../core/data/default_branches.dart';
import 'member_medical_info_screen.dart';

/// Écran affichant les détails d'un membre selon le design Figma.
/// Design: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=78-619
class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailScreen({
    super.key,
    required this.memberId,
  });

  Color _getBranchColor(String branchId) {
    final branch = DefaultBranches.getBranchById(branchId);
    if (branch != null) {
      final colorString = branch.color.replaceFirst('#', '');
      return Color(int.parse('FF$colorString', radix: 16));
    }
    return const Color(0xFF155DFC); // Bleu par défaut
  }

  String _getRelationLabel(ParentRelation relation) {
    switch (relation) {
      case ParentRelation.mother:
        return 'Mère';
      case ParentRelation.father:
        return 'Père';
      case ParentRelation.guardian:
        return 'Tuteur';
      case ParentRelation.other:
        return 'Autre';
    }
  }

  String _getPhoneTypeLabel(PhoneType type) {
    switch (type) {
      case PhoneType.regular:
        return 'Téléphone';
      case PhoneType.whatsapp:
        return 'WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Consumer2<MemberProvider, AdminProvider>(
        builder: (context, memberProvider, adminProvider, child) {
          final member = memberProvider.members.firstWhere(
            (m) => m.id == memberId,
            orElse: () => throw Exception('Member not found'),
          );
          
          // Charger les unités si nécessaire
          if (adminProvider.units.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              adminProvider.loadUnits();
            });
          }
          
          // Trouver le nom de l'unité
          String? unitName;
          if (member.unitId != null && member.unitId!.isNotEmpty) {
            try {
              final unit = adminProvider.units.firstWhere(
                (u) => u.id == member.unitId,
              );
              unitName = unit.name;
            } catch (e) {
              unitName = null;
            }
          }

          final branchColor = _getBranchColor(member.branchId);

          return Column(
            children: [
              // Header avec couleur de la branche
              Container(
                decoration: BoxDecoration(
                  color: branchColor,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton retour
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                // Retourner vers la liste des membres avec le branchId
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/members?branchId=${member.branchId}');
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                      color: Color(0xFFFFFFFF), // Blanc avec opacité 0.9
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Retour',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Boutons d'action (edit et delete)
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => context.go('/members/$memberId/edit'),
                                    tooltip: 'Modifier',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFB2C36).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _showDeleteDialog(
                                      context,
                                      member,
                                      memberProvider,
                                    ),
                                    tooltip: 'Supprimer',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Photo, nom, âge, date de naissance et unité
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo du membre
                            if (member.photoUrl != null && member.photoUrl!.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(member.photoUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    member.fullName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${member.age} ans • Né(e) le ${member.dateOfBirth.day.toString().padLeft(2, '0')}/${member.dateOfBirth.month.toString().padLeft(2, '0')}/${member.dateOfBirth.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  if (unitName != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      unitName!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Numéros de téléphone du membre (pour non-louveteaux)
                      if (member.phoneNumbers.isNotEmpty) ...[
                        _buildMemberPhoneSection(context, member),
                        const SizedBox(height: 16),
                      ],

                      // Contacts parents
                      if (member.parentContacts.isNotEmpty) ...[
                        _buildContactsSection(context, member),
                        const SizedBox(height: 16),
                      ],

                      // Fiche sanitaire
                      _buildMedicalSection(context, member),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemberPhoneSection(BuildContext context, Member member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Contact du membre',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste des numéros
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: member.phoneNumbers.map((phone) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // #f0fdf4
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      phone.type == PhoneType.whatsapp
                          ? Icons.chat
                          : Icons.phone,
                      size: 16,
                      color: const Color(0xFF00A63E), // #00a63e
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phone.number,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF00A63E), // #00a63e
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPhoneTypeLabel(phone.type),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF00A63E).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(BuildContext context, Member member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              const Icon(
                Icons.people,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Contacts parents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste des contacts
          ...member.parentContacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et relation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRelationLabel(contact.relation),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Numéros de téléphone (boutons verts)
                    if (contact.phoneNumbers.isNotEmpty)
                      ...contact.phoneNumbers.map((phone) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4), // #f0fdf4
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  phone.type == PhoneType.whatsapp
                                      ? Icons.chat
                                      : Icons.phone,
                                  size: 16,
                                  color: const Color(0xFF00A63E), // #00a63e
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  phone.number,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF00A63E), // #00a63e
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(BuildContext context, Member member) {
    final medicalInfo = member.medicalInfo;
    final hasAllergies = medicalInfo != null && medicalInfo.allergies.isNotEmpty;
    final hasIllnesses = medicalInfo != null && medicalInfo.illnesses.isNotEmpty;
    final hasMedications = medicalInfo != null && medicalInfo.medications.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              const Icon(
                Icons.medical_information,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Fiche sanitaire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Groupe sanguin
          if (medicalInfo?.bloodGroup != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // #f9fafb
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bloodtype,
                    size: 20,
                    color: Color(0xFF6A7282),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groupe sanguin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medicalInfo!.bloodGroup!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Allergies (en rouge si présentes)
          if (hasAllergies) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2), // #fef2f2
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        size: 16,
                        color: Color(0xFF82181A), // #82181a
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Allergies',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF82181A), // #82181a
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: medicalInfo!.allergies.map((allergy) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE2E2), // #ffe2e2
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          allergy,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC10007), // #c10007
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Maladies (en orange si présentes)
          if (hasIllnesses) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // #fff7ed
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        size: 16,
                        color: Color(0xFF9A3412), // #9a3412
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Maladies',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF9A3412), // #9a3412
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: medicalInfo!.illnesses.map((illness) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE2C7), // #ffe2c7
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          illness,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC2410C), // #c2410c
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Traitements/Médications (en bleu si présents)
          if (hasMedications) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // #eff6ff
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        size: 16,
                        color: Color(0xFF1E40AF), // #1e40af
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Traitements',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF1E40AF), // #1e40af
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: medicalInfo!.medications.map((medication) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE), // #dbeafe
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          medication,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E3A8A), // #1e3a8a
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Notes médicales
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB), // #f9fafb
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes médicales',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicalInfo?.notes?.isNotEmpty == true
                      ? medicalInfo!.notes!
                      : 'Aucune remarque particulière',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF364153), // #364153
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Member member,
    MemberProvider provider,
  ) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Supprimer le membre'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir supprimer ${member.fullName} ?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Motif de suppression *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Démission, transfert, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez indiquer un motif de suppression'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              final success = await provider.removeMember(member.id, reason);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membre supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Retourner vers la liste des membres avec le branchId
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/members?branchId=${member.branchId}');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Erreur lors de la suppression'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
