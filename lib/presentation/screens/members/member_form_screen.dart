import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/phone_number.dart';
import '../../../domain/entities/parent_contact.dart';
import '../../providers/member_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

/// Écran de formulaire pour créer/modifier un membre.
class MemberFormScreen extends StatefulWidget {
  final String? memberId; // null si création, défini si modification
  final String? branchId; // Branche par défaut

  const MemberFormScreen({
    super.key,
    this.memberId,
    this.branchId,
  });

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _illnessesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedBranchId = 'louveteaux';
  String? _selectedUnitId;
  String? _selectedBloodGroup;
  File? _selectedImage;
  String? _photoUrl;
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Numéros de téléphone du membre (pour non-louveteaux)
  List<_PhoneNumberEntry> _memberPhones = [];
  
  // Contacts des parents
  List<_ParentContactEntry> _parentContacts = [];

  @override
  void initState() {
    super.initState();
    final branchIdFromRoute = Uri.base.queryParameters['branchId'];
    final unitIdFromRoute = Uri.base.queryParameters['unitId'];
    _selectedBranchId = widget.branchId ?? branchIdFromRoute ?? 'louveteaux';
    _selectedUnitId = unitIdFromRoute;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      if (adminProvider.units.isEmpty) {
        adminProvider.loadUnits();
      }
      
      // Charger le membre si on est en mode modification
      if (widget.memberId != null) {
        await _loadMember();
      }
    });
  }

  /// Retourne vers la page de détails du membre si en mode modification,
  /// sinon vers la liste des membres avec le branchId actuel.
  void _navigateBack() {
    if (widget.memberId != null) {
      // En mode modification, rediriger vers la page de détails du membre
      context.go('/members/${widget.memberId}');
    } else {
      // En mode création, retourner vers la liste des membres
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/members?branchId=$_selectedBranchId');
      }
    }
  }

  Future<void> _loadMember() async {
    if (widget.memberId == null) return;
    
    final provider = Provider.of<MemberProvider>(context, listen: false);
    
    // Essayer d'abord de trouver le membre dans la liste chargée
    Member? member;
    try {
      member = provider.members.firstWhere(
        (m) => m.id == widget.memberId,
      );
    } catch (e) {
      // Si le membre n'est pas dans la liste, le charger par ID
      member = await provider.loadMemberById(widget.memberId!);
    }
    
    if (member == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Membre non trouvé'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    // Utiliser une variable locale pour éviter les problèmes de null safety
    final memberData = member!;
    
    setState(() {
      _firstNameController.text = memberData.firstName;
      _lastNameController.text = memberData.lastName;
      _selectedDate = memberData.dateOfBirth;
      _selectedBranchId = memberData.branchId;
      _selectedUnitId = memberData.unitId;
      _photoUrl = memberData.photoUrl;
      
      // Charger les numéros du membre
      _memberPhones = memberData.phoneNumbers.map((p) {
        return _PhoneNumberEntry(
          controller: TextEditingController(text: p.number),
          type: p.type,
        );
      }).toList();
      
      // Charger les contacts des parents
      _parentContacts = memberData.parentContacts.map((p) {
        return _ParentContactEntry(
          nameController: TextEditingController(text: p.name),
          relation: p.relation,
          phones: p.phoneNumbers.map((ph) {
            return _PhoneNumberEntry(
              controller: TextEditingController(text: ph.number),
              type: ph.type,
            );
          }).toList(),
        );
      }).toList();
      
      // Charger les informations médicales
      if (memberData.medicalInfo != null) {
        final info = memberData.medicalInfo!;
        _selectedBloodGroup = info.bloodGroup;
        _allergiesController.text = info.allergies.join(', ');
        _illnessesController.text = info.illnesses.join(', ');
        _medicationsController.text = info.medications.join(', ');
        _notesController.text = info.notes ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _allergiesController.dispose();
    _illnessesController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    for (final phone in _memberPhones) {
      phone.controller.dispose();
    }
    for (final contact in _parentContacts) {
      contact.nameController.dispose();
      for (final phone in contact.phones) {
        phone.controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _photoUrl;

    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('members/${widget.memberId ?? DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erreur lors de l\'upload de l\'image: $e');
      return _photoUrl;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addMemberPhone() {
    setState(() {
      _memberPhones.add(_PhoneNumberEntry(
        controller: TextEditingController(),
        type: PhoneType.regular,
      ));
    });
  }

  void _removeMemberPhone(int index) {
    setState(() {
      _memberPhones[index].controller.dispose();
      _memberPhones.removeAt(index);
    });
  }

  void _addParentContact() {
    setState(() {
      _parentContacts.add(_ParentContactEntry(
        nameController: TextEditingController(),
        relation: ParentRelation.mother,
        phones: [],
      ));
    });
  }

  void _removeParentContact(int index) {
    setState(() {
      _parentContacts[index].nameController.dispose();
      for (final phone in _parentContacts[index].phones) {
        phone.controller.dispose();
      }
      _parentContacts.removeAt(index);
    });
  }

  void _addParentPhone(int contactIndex) {
    setState(() {
      _parentContacts[contactIndex].phones.add(_PhoneNumberEntry(
        controller: TextEditingController(),
        type: PhoneType.regular,
      ));
    });
  }

  void _removeParentPhone(int contactIndex, int phoneIndex) {
    setState(() {
      _parentContacts[contactIndex].phones[phoneIndex].controller.dispose();
      _parentContacts[contactIndex].phones.removeAt(phoneIndex);
    });
  }

  Future<void> _saveMember() async {
    if (_isSaving || _isLoading) return;

    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Validation du formulaire échouée');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier que la date de naissance est sélectionnée
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de naissance'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier que la branche est sélectionnée
    if (_selectedBranchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une branche'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaving = true;
    });

    try {
      // Upload de l'image si nécessaire
      final uploadedPhotoUrl = await _uploadImage();
      debugPrint('📸 Photo URL: $uploadedPhotoUrl');

      final provider = Provider.of<MemberProvider>(context, listen: false);
    
      // Construire les numéros de téléphone du membre
      final memberPhoneNumbers = _memberPhones
          .where((p) => p.controller.text.trim().isNotEmpty)
          .map((p) => PhoneNumber(
                number: p.controller.text.trim(),
                type: p.type,
              ))
          .toList();
      debugPrint('📱 Numéros du membre: ${memberPhoneNumbers.length}');

      // Construire les contacts des parents
      final parentContacts = _parentContacts
          .where((c) => c.nameController.text.trim().isNotEmpty)
          .map((c) {
            final phones = c.phones
                .where((p) => p.controller.text.trim().isNotEmpty)
                .map((p) => PhoneNumber(
                      number: p.controller.text.trim(),
                      type: p.type,
                    ))
                .toList();
            return ParentContact(
              name: c.nameController.text.trim(),
              phoneNumbers: phones,
              relation: c.relation,
            );
          })
          .toList();
      debugPrint('👨‍👩‍👧 Contacts parents: ${parentContacts.length}');

    // Construire les informations médicales
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

      final medicalInfo = (allergies.isNotEmpty ||
              illnesses.isNotEmpty ||
              medications.isNotEmpty ||
              _selectedBloodGroup != null ||
              _notesController.text.trim().isNotEmpty)
          ? MedicalInfo(
              allergies: allergies,
              illnesses: illnesses,
              medications: medications,
              bloodGroup: _selectedBloodGroup,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            )
          : null;
      debugPrint('🏥 Infos médicales: ${medicalInfo != null ? "présentes" : "aucune"}');

      // Pour la modification, l'ID doit être présent et non vide
      // Pour la création, l'ID sera généré par le repository si vide
      final member = Member(
        id: widget.memberId ?? '', // Pour modification: ID existant, pour création: sera généré
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _selectedDate!,
        branchId: _selectedBranchId,
        unitId: _selectedUnitId?.isEmpty == true ? null : _selectedUnitId,
        photoUrl: uploadedPhotoUrl ?? _photoUrl, // Préserver l'image existante si pas de nouvelle image
        phoneNumbers: memberPhoneNumbers,
        parentContacts: parentContacts,
        medicalInfo: medicalInfo,
      );

      debugPrint('💾 Sauvegarde du membre:');
      debugPrint('  - ID: ${member.id}');
      debugPrint('  - Nom: ${member.firstName} ${member.lastName}');
      debugPrint('  - Branche: ${member.branchId}');
      debugPrint('  - Unité: ${member.unitId ?? "aucune"}');
      debugPrint('  - Date de naissance: ${member.dateOfBirth}');
      debugPrint('  - Photo: ${member.photoUrl ?? "aucune"}');
      debugPrint('  - Téléphones: ${member.phoneNumbers.length}');
      debugPrint('  - Contacts parents: ${member.parentContacts.length}');
      debugPrint('  - Infos médicales: ${member.medicalInfo != null ? "oui" : "non"}');

      final success = widget.memberId == null
          ? await provider.addMember(member)
          : await provider.modifyMember(member);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSaving = false;
      });

      if (success) {
        debugPrint('✅ Membre sauvegardé avec succès');
        // Fermer immédiatement après succès pour éviter le double ajout
        if (mounted) {
          _navigateBack();
        }
        
        // Afficher le message de succès après la navigation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.memberId == null
                    ? 'Membre ajouté avec succès'
                    : 'Membre modifié avec succès',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('❌ Erreur lors de la sauvegarde: ${provider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception lors de la sauvegarde: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  bool get _isLouveteaux => _selectedBranchId == 'louveteaux';

  @override
  Widget build(BuildContext context) {
    // PopScope pour empêcher le retour pendant la sauvegarde
    return PopScope(
      canPop: !_isSaving && !_isLoading, // Empêcher le retour pendant la sauvegarde
      onPopInvoked: (bool didPop) {
        if (didPop) return; // Le pop s'est déjà fait, rien à faire
        
        // Si on n'est pas en train de sauvegarder, permettre le retour normal
        if (!_isSaving && !_isLoading) {
          _navigateBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.memberId == null ? 'Ajouter un membre' : 'Modifier un membre'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (_isSaving || _isLoading) ? null : _navigateBack,
            tooltip: 'Retour',
          ),
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
            else ...[
              TextButton(
                onPressed: (_isSaving || _isLoading) ? null : _navigateBack,
                child: const Text('Annuler'),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: (_isSaving || _isLoading) ? null : _saveMember,
                tooltip: 'Enregistrer',
              ),
            ],
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo du membre
                _buildPhotoSection(),
                const SizedBox(height: 24),
                
                // Informations de base
                _buildSectionTitle('Informations de base'),
                const SizedBox(height: 12),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                
                // Contact parent
                _buildSectionTitle('Contact parent'),
                const SizedBox(height: 12),
                _buildParentContactSection(),
                const SizedBox(height: 24),
                
                // Numéros du membre (non-louveteaux uniquement)
                if (!_isLouveteaux) ...[
                  _buildSectionTitle('Contact du membre'),
                  const SizedBox(height: 12),
                  _buildMemberPhoneSection(),
                  const SizedBox(height: 24),
                ],
                
                // Fiche sanitaire
                _buildSectionTitle('Fiche sanitaire'),
                const SizedBox(height: 12),
                _buildMedicalInfoSection(),
                const SizedBox(height: 32),
                
                // Boutons d'action
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0A0A0A),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: (_isSaving || _isLoading) ? null : _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_photoUrl != null
                          ? NetworkImage(_photoUrl!) as ImageProvider
                          : null),
                  child: _selectedImage == null && _photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF314158),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: (_isSaving || _isLoading) ? null : _pickImage,
            icon: const Icon(Icons.photo_library, size: 18),
            label: const Text('Ajouter une photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _firstNameController,
          enabled: !_isSaving && !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Prénom *',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) => Validators.validateRequired(value, 'Le prénom'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          enabled: !_isSaving && !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Nom *',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) => Validators.validateRequired(value, 'Le nom'),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: (_isSaving || _isLoading) ? null : () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date de naissance *',
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: _selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: (_isSaving || _isLoading) ? null : () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                    )
                  : null,
            ),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Sélectionner une date',
              style: _selectedDate == null
                  ? TextStyle(color: Colors.grey[600])
                  : null,
            ),
          ),
        ),
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              'Âge: ${_calculateAge(_selectedDate!)} ans',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedBranchId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Branche *',
            prefixIcon: Icon(Icons.group),
          ),
          items: const [
            DropdownMenuItem(
              value: 'louveteaux',
              child: Text('Louveteaux (7-12 ans)'),
            ),
            DropdownMenuItem(
              value: 'eclaireurs',
              child: Text('Éclaireurs (13-16 ans)'),
            ),
            DropdownMenuItem(
              value: 'sinikie',
              child: Text('Sinikié (17-20 ans)'),
            ),
            DropdownMenuItem(
              value: 'routiers',
              child: Text('Routiers (21-25 ans)'),
            ),
          ],
          onChanged: (_isSaving || _isLoading) ? null : (value) {
            if (value != null) {
              setState(() {
                _selectedBranchId = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Consumer2<AdminProvider, AuthProvider>(
          builder: (context, adminProvider, authProvider, child) {
            final currentUser = authProvider.currentUser;
            if (currentUser == null) {
              return const SizedBox.shrink();
            }
            
            // Seules les unités de l'utilisateur connecté doivent être disponibles
            // Pour les admins : unités de leur groupe (groupId == user.unitId)
            // Pour les autres : seulement leur unité (id == user.unitId)
            final availableUnits = currentUser.hasAdminAccess
                ? adminProvider.units
                    .where((u) => u.groupId == currentUser.unitId)
                    .toList()
                : adminProvider.units
                    .where((u) => u.id == currentUser.unitId)
                    .toList();
            
            if (availableUnits.isEmpty) {
              if (adminProvider.units.isEmpty) {
                // Utiliser addPostFrameCallback pour éviter setState() during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    adminProvider.loadUnits();
                  }
                });
              }
              return const SizedBox.shrink();
            }
            
            return DropdownButtonFormField<String>(
              value: _selectedUnitId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Unité',
                prefixIcon: Icon(Icons.business),
                hintText: 'Sélectionner une unité (optionnel)',
              ),
              onChanged: (_isSaving || _isLoading) ? null : (value) {
                setState(() {
                  _selectedUnitId = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Aucune unité'),
                ),
                ...availableUnits.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit.id,
                    child: Text(unit.name),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildParentContactSection() {
    if (_parentContacts.isEmpty) {
      return Column(
        children: [
          OutlinedButton.icon(
            onPressed: (_isSaving || _isLoading) ? null : _addParentContact,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un contact parent'),
          ),
        ],
      );
    }

    return Column(
      children: [
        ...List.generate(_parentContacts.length, (index) {
          final contact = _parentContacts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Contact parent',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: (_isSaving || _isLoading) ? null : () => _removeParentContact(index),
                        tooltip: 'Supprimer ce contact',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contact.nameController,
                    enabled: !_isSaving && !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ParentRelation>(
                    value: contact.relation,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Relation',
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ParentRelation.mother,
                        child: Text('Mère'),
                      ),
                      DropdownMenuItem(
                        value: ParentRelation.father,
                        child: Text('Père'),
                      ),
                      DropdownMenuItem(
                        value: ParentRelation.guardian,
                        child: Text('Tuteur'),
                      ),
                      DropdownMenuItem(
                        value: ParentRelation.other,
                        child: Text('Autre'),
                      ),
                    ],
                    onChanged: (_isSaving || _isLoading) ? null : (value) {
                      if (value != null) {
                        setState(() {
                          contact.relation = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(contact.phones.length, (phoneIndex) {
                    return _buildPhoneNumberField(
                      contact.phones[phoneIndex],
                      onRemove: contact.phones.length > 1
                          ? () => _removeParentPhone(index, phoneIndex)
                          : null,
                    );
                  }),
                  const SizedBox(height: 8),
                  if (contact.phones.length < 2)
                    OutlinedButton.icon(
                      onPressed: (_isSaving || _isLoading) ? null : () => _addParentPhone(index),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Ajouter un numéro'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: (_isSaving || _isLoading) ? null : _addParentContact,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un autre contact parent'),
        ),
      ],
    );
  }

  Widget _buildMemberPhoneSection() {
    if (_memberPhones.isEmpty) {
      return Column(
        children: [
          OutlinedButton.icon(
            onPressed: (_isSaving || _isLoading) ? null : _addMemberPhone,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un numéro de téléphone'),
          ),
        ],
      );
    }

    return Column(
      children: [
        ...List.generate(_memberPhones.length, (index) {
          return _buildPhoneNumberField(
            _memberPhones[index],
            onRemove: _memberPhones.length > 1
                ? () => _removeMemberPhone(index)
                : null,
          );
        }),
        if (_memberPhones.length < 2)
          OutlinedButton.icon(
            onPressed: (_isSaving || _isLoading) ? null : _addMemberPhone,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter un autre numéro'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneNumberField(
    _PhoneNumberEntry entry, {
    VoidCallback? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<PhoneType>(
              value: entry.type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.phone),
              ),
              items: const [
                DropdownMenuItem(
                  value: PhoneType.regular,
                  child: Text('Téléphone'),
                ),
                DropdownMenuItem(
                  value: PhoneType.whatsapp,
                  child: Row(
                    children: [
                      Icon(Icons.chat, size: 18),
                      SizedBox(width: 8),
                      Text('WhatsApp'),
                    ],
                  ),
                ),
              ],
              onChanged: (_isSaving || _isLoading) ? null : (value) {
                if (value != null) {
                  setState(() {
                    entry.type = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: entry.controller,
              enabled: !_isSaving && !_isLoading,
              decoration: InputDecoration(
                labelText: 'Numéro',
                hintText: '70 12 34 56',
                suffixIcon: onRemove != null
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: (_isSaving || _isLoading) ? null : onRemove,
                      )
                    : null,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  return Validators.validatePhone(value);
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          isExpanded: true, // Pour éviter l'overflow
          decoration: const InputDecoration(
            labelText: 'Groupe sanguin',
            prefixIcon: Icon(Icons.bloodtype),
            hintText: 'Sélectionner (optionnel)',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Non renseigné'),
            ),
            ...['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'].map((group) {
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _allergiesController,
          decoration: const InputDecoration(
            labelText: 'Allergies (séparées par des virgules)',
            prefixIcon: Icon(Icons.warning),
            hintText: 'Arachides, Lactose...',
            helperText: 'Optionnel - Séparez les allergies par des virgules',
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _illnessesController,
          enabled: !_isSaving && !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Maladies (séparées par des virgules)',
            prefixIcon: Icon(Icons.health_and_safety),
            hintText: 'Asthme, Diabète...',
            helperText: 'Optionnel - Séparez les maladies par des virgules',
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _medicationsController,
          enabled: !_isSaving && !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Traitements (séparés par des virgules)',
            prefixIcon: Icon(Icons.medication),
            hintText: 'Ventoline, Insuline...',
            helperText: 'Optionnel - Séparez les traitements par des virgules',
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          enabled: !_isSaving && !_isLoading,
          decoration: const InputDecoration(
            labelText: 'Notes médicales',
            prefixIcon: Icon(Icons.note),
            hintText: 'Remarques particulières...',
            helperText: 'Optionnel - Informations médicales supplémentaires',
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (_isLoading || _isSaving) ? null : _navigateBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (_isLoading || _isSaving) ? null : _saveMember,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF155DFC),
            ),
            child: (_isLoading || _isSaving)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Ajouter'),
          ),
        ),
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final monthDiff = today.month - birthDate.month;
    if (monthDiff < 0 || (monthDiff == 0 && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// Classe helper pour gérer un numéro de téléphone dans le formulaire.
class _PhoneNumberEntry {
  final TextEditingController controller;
  PhoneType type;

  _PhoneNumberEntry({
    required this.controller,
    required this.type,
  });
}

/// Classe helper pour gérer un contact parent dans le formulaire.
class _ParentContactEntry {
  final TextEditingController nameController;
  ParentRelation relation;
  List<_PhoneNumberEntry> phones;

  _ParentContactEntry({
    required this.nameController,
    required this.relation,
    this.phones = const [],
  });
}
