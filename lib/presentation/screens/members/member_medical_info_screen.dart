import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/member.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_colors.dart';
import 'member_medical_form_screen.dart';

/// Écran affichant les informations médicales d'un membre.
class MemberMedicalInfoScreen extends StatelessWidget {
  final String memberId;

  const MemberMedicalInfoScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations médicales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MemberMedicalFormScreen(
                    memberId: memberId,
                  ),
                ),
              );
            },
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: Consumer<MemberProvider>(
        builder: (context, provider, child) {
          final member = provider.members.firstWhere(
            (m) => m.id == memberId,
            orElse: () => throw Exception('Member not found'),
          );

          final medicalInfo = member.medicalInfo;

          if (medicalInfo == null ||
              (medicalInfo.allergies.isEmpty &&
                  medicalInfo.illnesses.isEmpty &&
                  medicalInfo.medications.isEmpty &&
                  medicalInfo.bloodGroup == null &&
                  medicalInfo.notes == null)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune information médicale',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (medicalInfo.bloodGroup != null) ...[
                  _buildSectionTitle(context, 'Groupe sanguin'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bloodtype,
                            color: AppColors.error,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            medicalInfo.bloodGroup!,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (medicalInfo.allergies.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Allergies'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: medicalInfo.allergies.map((allergy) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    allergy,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (medicalInfo.illnesses.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Maladies'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: medicalInfo.illnesses.map((illness) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    illness,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (medicalInfo.medications.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Traitements en cours'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: medicalInfo.medications.map((medication) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.medication,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    medication,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (medicalInfo.notes != null && medicalInfo.notes!.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Notes médicales'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        medicalInfo.notes!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

