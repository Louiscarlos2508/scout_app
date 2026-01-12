import 'package:flutter/material.dart';
import '../../../domain/entities/member.dart';
import '../../theme/app_colors.dart';

/// Widget carte pour afficher un membre de manière compacte.
class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final branchColor = _getBranchColor(member.branchId);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: branchColor.withOpacity(0.2),
                    child: Text(
                      member.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: branchColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${member.age} ans',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (member.parentPhone != null)
                    IconButton(
                      icon: const Icon(Icons.phone),
                      color: AppColors.primary,
                      onPressed: () {
                        // TODO: Implémenter l'appel téléphonique
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appeler ${member.parentPhone}'),
                          ),
                        );
                      },
                      tooltip: 'Appeler les parents',
                    ),
                ],
              ),
              if (member.medicalInfo != null &&
                  (member.medicalInfo!.allergies.isNotEmpty ||
                      member.medicalInfo!.illnesses.isNotEmpty ||
                      member.medicalInfo!.medications.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Infos médicales disponibles',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
