import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../data/models/user_model.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/constants/firestore_constants.dart';

/// Écran de profil utilisateur.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  bool _isUploading = false;

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
        await _uploadProfilePicture();
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

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) return;

      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('users/${user.id}/profile.jpg');
      
      await ref.putFile(_selectedImage!);
      final downloadUrl = await ref.getDownloadURL();

      // Mettre à jour Firestore
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .doc(user.id)
          .update({'photoUrl': downloadUrl});

      // Mettre à jour le provider
      authProvider.updateCurrentUser(
        UserModel(
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          phoneNumber: user.phoneNumber,
          dateOfBirth: user.dateOfBirth,
          role: user.role,
          status: user.status,
          unitId: user.unitId,
          branchId: user.branchId,
          photoUrl: downloadUrl,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AdminProvider>(
      builder: (context, authProvider, adminProvider, child) {
        final user = authProvider.currentUser;
        
        // Charger les unités si nécessaire
        if (adminProvider.units.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            adminProvider.loadUnits();
          });
        }

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profil'),
            ),
            body: const Center(
              child: Text('Aucun utilisateur connecté'),
            ),
          );
        }

        // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
        return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Header avec gradient bleu foncé
                  Container(
                    height: 362,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF45556C), // #45556C
                          Color(0xFF314158), // #314158
                          Color(0xFF1D293D), // #1D293D
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Bouton retour
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => context.go('/home'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                      color: Color(0xFFE2E8F0),
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
                            const SizedBox(height: 20),
                            // Avatar avec photo de profil
                            GestureDetector(
                              onTap: _isUploading ? null : _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 3.657,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 25,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: _selectedImage != null
                                          ? Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : (user.photoUrl != null &&
                                                  user.photoUrl!.isNotEmpty)
                                              ? Image.network(
                                                  user.photoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (context, error, stackTrace) {
                                                    return Center(
                                                      child: Text(
                                                        user.firstName[0]
                                                                .toUpperCase() +
                                                            (user.lastName
                                                                    .isNotEmpty
                                                                ? user.lastName[0]
                                                                    .toUpperCase()
                                                                : ''),
                                                        style: const TextStyle(
                                                          fontSize: 40,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: Text(
                                                    user.firstName[0]
                                                            .toUpperCase() +
                                                        (user.lastName.isNotEmpty
                                                            ? user.lastName[0]
                                                                .toUpperCase()
                                                            : ''),
                                                    style: const TextStyle(
                                                      fontSize: 40,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  ),
                                  if (_isUploading)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF314158),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Nom de l'utilisateur
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Bouton de déconnexion
                                InkWell(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Déconnexion'),
                                        content: const Text(
                                          'Êtes-vous sûr de vouloir vous déconnecter ?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              'Déconnexion',
                                              style: TextStyle(
                                                  color: Color(0xFFFB2C36)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && context.mounted) {
                                      await authProvider.signOut();
                                      if (context.mounted) {
                                        context.go('/login');
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 42.437,
                                    height: 42.437,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFB2C36)
                                          .withOpacity(0.2),
                                      border: Border.all(
                                        color: const Color(0xFFFFA2A3)
                                            .withOpacity(0.3),
                                        width: 1.219,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(11.219),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Badge rôle
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00D492),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getRoleLabel(user.role),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Contenu principal
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Section Informations personnelles
                        _buildPersonalInfoSection(context, user),
                        const SizedBox(height: 24),
                        // Section Organisation
                        _buildOrganizationSection(context, user, adminProvider),
                        const SizedBox(height: 24),
                        // Section Statistiques
                        _buildStatisticsSection(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1.219,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec bouton d'édition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: const Color(0xFF6A7282),
                onPressed: () {
                  // TODO: Implémenter l'édition
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Nom complet
          _buildInfoField(
            label: 'Nom complet',
            value: user.fullName,
          ),
          const SizedBox(height: 16),
          // Email
          _buildInfoField(
            label: 'Email',
            value: user.email,
            icon: Icons.email_outlined,
            isEmpty: user.email.isEmpty,
          ),
          const SizedBox(height: 16),
          // Téléphone
          _buildInfoField(
            label: 'Téléphone',
            value: user.email, // TODO: Ajouter le champ téléphone à User
            icon: Icons.phone_outlined,
            isEmpty: true, // TODO: Vérifier si téléphone est renseigné
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    IconData? icon,
    bool isEmpty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A5565),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: EdgeInsets.only(
            left: 16,
            right: icon != null ? 0 : 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF6A7282),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  isEmpty ? 'Non renseigné' : value,
                  style: TextStyle(
                    fontSize: isEmpty ? 14 : 16,
                    color: isEmpty
                        ? const Color(0xFF6A7282)
                        : const Color(0xFF101828),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationSection(BuildContext context, User user, AdminProvider adminProvider) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1.219,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organisation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          // Unité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF9FAFB),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unité',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUnitDisplayName(user.unitId, adminProvider),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF62748E),
                        Color(0xFF45556C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Branche
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0FDF4),
                  Color(0xFFF9FAFB),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Branche',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBranchDisplayName(user.branchId),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.group,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Rôle et permissions
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFBEB),
                  Color(0xFFFEF3C6),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFEE683).withOpacity(0.5),
                width: 1.219,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rôle et permissions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBB4D00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRoleLabel(user.role),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B3306),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRoleDescription(user.role),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBB4D00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1.219,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFF9FAFB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF314158),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Actions cette semaine',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A5565),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFECFDF5),
                        Color(0xFFD0FAE5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007A55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Taux d\'activité',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A5565),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.unitLeader:
        return 'Chef d\'Unité';
      case UserRole.assistantLeader:
        return 'Assistant CU';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Accès complet à toutes les fonctionnalités';
      case UserRole.unitLeader:
        return 'Accès complet à toutes les branches de l\'unité';
      case UserRole.assistantLeader:
        return 'Accès à la branche assignée';
    }
  }

  String _getUnitDisplayName(String unitId, AdminProvider adminProvider) {
    // Récupérer le vrai nom de l'unité depuis le provider
    try {
      final unit = adminProvider.units.firstWhere(
        (u) => u.id == unitId,
      );
      return unit.name;
    } catch (e) {
      // Si l'unité n'est pas trouvée, utiliser une transformation basique comme fallback
      if (unitId.toLowerCase().contains('alpha')) {
        return 'Unité Alpha';
      }
      final parts = unitId.split(RegExp(r'[_\-\s]+'));
      final capitalized = parts.map((part) {
        if (part.isEmpty) return '';
        return part[0].toUpperCase() + part.substring(1).toLowerCase();
      }).join(' ');
      return 'Unité $capitalized';
    }
  }

  String _getBranchDisplayName(String branchId) {
    final branch = DefaultBranches.getBranchById(branchId);
    return branch?.name ?? branchId;
  }
}
