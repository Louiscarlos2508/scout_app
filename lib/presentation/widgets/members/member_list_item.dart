import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/member.dart';
import '../../theme/app_colors.dart';

/// Widget pour afficher un membre dans une liste.
class MemberListItem extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;

  const MemberListItem({
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: branchColor.withOpacity(0.2),
          child: Text(
            member.firstName[0].toUpperCase(),
            style: TextStyle(
              color: branchColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.fullName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${member.age} ans',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (member.medicalInfo != null &&
                (member.medicalInfo!.allergies.isNotEmpty ||
                    member.medicalInfo!.illnesses.isNotEmpty ||
                    member.medicalInfo!.medications.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_information,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Infos médicales',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: member.parentPhone != null
            ? IconButton(
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
              )
            : null,
        onTap: onTap ??
            () {
              context.go('/members/${member.id}');
            },
      ),
    );
  }
}
