import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/user.dart';

/// Écran d'inscription pour les nouveaux utilisateurs.
/// Design basé sur Figma: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=79-942
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedUnitId;
  UserRole? _selectedRole = UserRole.unitLeader; // Par défaut Chef d'Unité
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (adminProvider.units.isEmpty) {
      adminProvider.loadUnits();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateAvailableBranches(String? unitId) {
    if (unitId == null) {
      return;
    }
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un rôle'),
        ),
      );
      return;
    }

    if (_selectedUnitId == null || _selectedUnitId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une unité'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Séparer le nom complet en prénom et nom
    final fullName = _fullNameController.text.trim();
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : (nameParts.length == 1 ? '' : '');

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nom complet (prénom et nom)'),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Pour l'inscription, on utilise unitLeader par défaut (sera changé par l'admin)
    // Mais on garde le rôle sélectionné pour référence
    final result = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: '', // Sera complété plus tard
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Valeur par défaut
      unitId: _selectedUnitId!,
      branchId: '', // Sera assigné par l'admin
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (user) {
        // Rediriger vers l'écran d'attente
        if (user.phoneNumber.isEmpty ||
            user.unitId.isEmpty ||
            user.branchId.isEmpty) {
          context.go('/complete-google-info');
        } else if (user.isPending && !user.hasAdminAccess) {
          context.go('/waiting-approval');
        } else if (user.hasAdminAccess) {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  const Color(0xFF314158), // #314158
                  const Color(0xFF1D293D), // #1D293D
                  const Color(0xFF101828), // #101828
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Effets de blur en arrière-plan
                  Positioned(
                    left: 26,
                    top: 66,
                    child: Container(
                      width: 317,
                      height: 317,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05 * 0.351),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -53,
                    top: 615,
                    child: Container(
                      width: 390,
                      height: 390,
                      decoration: BoxDecoration(
                        color: const Color(0xFF62748E).withOpacity(0.1 * 0.332),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Contenu principal
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            // Logo dans un conteneur blanc arrondi
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flag,
                                size: 40,
                                color: Color(0xFF314158),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Titre "Inscription"
                            const Text(
                              'Inscription',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                letterSpacing: 0,
                                height: 1.11, // 40/36
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Sous-titre
                            Text(
                              'Créez votre compte Scout Manager',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFFCAD5E2), // #cad5e2
                                letterSpacing: 0,
                                height: 1.5, // 24/16
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            // Formulaire de connexion dans un conteneur blanc
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 16),
                                    // Champ Nom complet
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Nom complet',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _fullNameController,
                                          decoration: InputDecoration(
                                            hintText: 'Ex: Chef Mamadou',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF717182),
                                              fontSize: 16,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.person_outlined,
                                              size: 20,
                                              color: Color(0xFF717182),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF314158),
                                                width: 1.219,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 12,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Le nom complet est requis';
                                            }
                                            final parts = value.trim().split(' ');
                                            if (parts.length < 2) {
                                              return 'Veuillez entrer votre prénom et nom';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Champ Email
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            hintText: 'votre.email@exemple.com',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF717182),
                                              fontSize: 16,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              size: 20,
                                              color: Color(0xFF717182),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF314158),
                                                width: 1.219,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 12,
                                            ),
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          validator: Validators.validateEmail,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Champ Mot de passe
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Mot de passe',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          enabled: !_isLoading,
                                          decoration: InputDecoration(
                                            hintText: '••••••••',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF717182),
                                              fontSize: 16,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.lock_outlined,
                                              size: 20,
                                              color: Color(0xFF717182),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                size: 20,
                                                color: const Color(0xFF717182),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF314158),
                                                width: 1.219,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 12,
                                            ),
                                          ),
                                          textInputAction: TextInputAction.next,
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          validator: Validators.validatePassword,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Champ Confirmer le mot de passe
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Confirmer le mot de passe',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          enabled: !_isLoading,
                                          decoration: InputDecoration(
                                            hintText: '••••••••',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF717182),
                                              fontSize: 16,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.lock_outlined,
                                              size: 20,
                                              color: Color(0xFF717182),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                size: 20,
                                                color: const Color(0xFF717182),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      !_obscureConfirmPassword;
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1.219,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF314158),
                                                width: 1.219,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 12,
                                            ),
                                          ),
                                          textInputAction: TextInputAction.next,
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            if (value != _passwordController.text) {
                                              return 'Les mots de passe ne correspondent pas';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Sélection du rôle
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Rôle',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF364153),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Option Chef d'Unité
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedRole = UserRole.unitLeader;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(17.219),
                                                  decoration: BoxDecoration(
                                                    color: _selectedRole == UserRole.unitLeader
                                                        ? const Color(0xFFF8FAFC)
                                                        : Colors.white,
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(
                                                      color: _selectedRole == UserRole.unitLeader
                                                          ? const Color(0xFF62748E)
                                                          : const Color(0xFFE5E7EB),
                                                      width: 1.219,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: _selectedRole == UserRole.unitLeader
                                                              ? const Color(0xFF62748E)
                                                              : const Color(0xFFF3F4F6),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Icon(
                                                          Icons.people_outlined,
                                                          size: 20,
                                                          color: _selectedRole == UserRole.unitLeader
                                                              ? Colors.white
                                                              : const Color(0xFF101828),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Chef d\'Unité',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(0xFF101828),
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Accès complet',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF6A7282),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Option Assistant CU
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedRole = UserRole.assistantLeader;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(17.219),
                                                  decoration: BoxDecoration(
                                                    color: _selectedRole == UserRole.assistantLeader
                                                        ? const Color(0xFFF8FAFC)
                                                        : Colors.white,
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(
                                                      color: _selectedRole == UserRole.assistantLeader
                                                          ? const Color(0xFF62748E)
                                                          : const Color(0xFFE5E7EB),
                                                      width: 1.219,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: _selectedRole == UserRole.assistantLeader
                                                              ? const Color(0xFF62748E)
                                                              : const Color(0xFFF3F4F6),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Icon(
                                                          Icons.person_outlined,
                                                          size: 20,
                                                          color: _selectedRole == UserRole.assistantLeader
                                                              ? Colors.white
                                                              : const Color(0xFF101828),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Assistant CU',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(0xFF101828),
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Accès limité',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF6A7282),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Unité
                                    Consumer<AdminProvider>(
                                      builder: (context, adminProvider, child) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Unité',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF364153),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            DropdownButtonFormField<String>(
                                              value: _selectedUnitId,
                                              decoration: InputDecoration(
                                                hintText: 'Sélectionnez une unité',
                                                hintStyle: const TextStyle(
                                                  color: Color(0xFF717182),
                                                  fontSize: 16,
                                                ),
                                                prefixIcon: const Icon(
                                                  Icons.business_outlined,
                                                  size: 20,
                                                  color: Color(0xFF717182),
                                                ),
                                                suffixIcon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 20,
                                                  color: Color(0xFF717182),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE5E7EB),
                                                    width: 1.219,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE5E7EB),
                                                    width: 1.219,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF314158),
                                                    width: 1.219,
                                                  ),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 40,
                                                  vertical: 12,
                                                ),
                                              ),
                                              items: adminProvider.units.map((unit) {
                                                return DropdownMenuItem<String>(
                                                  value: unit.id,
                                                  child: Text(unit.name),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedUnitId = value;
                                                });
                                                _updateAvailableBranches(value);
                                              },
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Veuillez sélectionner une unité';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Bouton "Créer mon compte" avec dégradé
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF45556C),
                                            Color(0xFF314158),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, -4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _signUp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Text(
                                                'Créer mon compte',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Lien "Vous avez déjà un compte ?"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Vous avez déjà un compte ? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF45556C),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : () => context.pop(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF45556C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay de chargement
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF314158),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Création du compte...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF364153),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
