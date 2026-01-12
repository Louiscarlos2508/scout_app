import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/member.dart';
import '../../providers/member_provider.dart';

/// Écran de formulaire pour éditer les informations médicales d'un membre.
class MemberMedicalFormScreen extends StatefulWidget {
  final String memberId;

  const MemberMedicalFormScreen({
    super.key,
    required this.memberId,
  });

  @override
  State<MemberMedicalFormScreen> createState() => _MemberMedicalFormScreenState();
}

class _MemberMedicalFormScreenState extends State<MemberMedicalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergiesController = TextEditingController();
  final _illnessesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedBloodGroup;
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  void _loadMedicalInfo() {
    final provider = Provider.of<MemberProvider>(context, listen: false);
    final member = provider.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => throw Exception('Member not found'),
    );

    if (member.medicalInfo != null) {
      final info = member.medicalInfo!;
      _allergiesController.text = info.allergies.join(', ');
      _illnessesController.text = info.illnesses.join(', ');
      _medicationsController.text = info.medications.join(', ');
      _notesController.text = info.notes ?? '';
      _selectedBloodGroup = info.bloodGroup;
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _illnessesController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicalInfo() async {
    if (_isSaving || _isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaving = true;
    });

    final provider = Provider.of<MemberProvider>(context, listen: false);
    final member = provider.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => throw Exception('Member not found'),
    );

    // Parser les listes depuis les champs texte (séparés par des virgules)
    final allergies = _allergiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final illnesses = _illnessesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final medications = _medicationsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final medicalInfo = MedicalInfo(
      allergies: allergies,
      illnesses: illnesses,
      medications: medications,
      bloodGroup: _selectedBloodGroup?.isEmpty == true ? null : _selectedBloodGroup,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final updatedMember = Member(
      id: member.id,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      unitId: member.unitId,
      photoUrl: member.photoUrl,
      phoneNumbers: member.phoneNumbers,
      parentContacts: member.parentContacts,
      medicalInfo: medicalInfo,
      lastSync: member.lastSync,
    );

    final success = await provider.modifyMember(updatedMember);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations médicales mises à jour'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations médicales'),
        actions: [
          if (_isLoading || _isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveMedicalInfo,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Groupe sanguin (optionnel)
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  prefixIcon: Icon(Icons.bloodtype),
                  hintText: 'Sélectionner un groupe sanguin (optionnel)',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Non renseigné'),
                  ),
                  ..._bloodGroups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Allergies (optionnel)
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  prefixIcon: Icon(Icons.warning),
                  hintText: 'Séparer par des virgules (ex: Arachides, Lait)',
                  helperText: 'Optionnel - Séparez les allergies par des virgules',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Maladies (optionnel)
              TextFormField(
                controller: _illnessesController,
                decoration: const InputDecoration(
                  labelText: 'Maladies',
                  prefixIcon: Icon(Icons.health_and_safety),
                  hintText: 'Séparer par des virgules (ex: Asthme, Diabète)',
                  helperText: 'Optionnel - Séparez les maladies par des virgules',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Traitements (optionnel)
              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Traitements en cours',
                  prefixIcon: Icon(Icons.medication),
                  hintText: 'Séparer par des virgules (ex: Ventoline, Insuline)',
                  helperText: 'Optionnel - Séparez les traitements par des virgules',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Notes (optionnel)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes médicales',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Informations complémentaires',
                  helperText: 'Optionnel - Informations médicales supplémentaires',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isLoading || _isSaving) ? null : _saveMedicalInfo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: (_isLoading || _isSaving)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
