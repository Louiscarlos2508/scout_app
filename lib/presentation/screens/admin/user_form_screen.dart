import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/user.dart';
import '../../../core/data/default_branches.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

/// Écran de formulaire pour créer un utilisateur.
class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  UserRole _selectedRole = UserRole.unitLeader;
  String? _selectedUnitId;
  String? _selectedBranchId;
  final List<String> _availableBranchIds = [];
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Charger les unités si nécessaire
    if (adminProvider.units.isEmpty) {
      adminProvider.loadUnits();
    }

    // Si une unité est passée en paramètre, la pré-sélectionner
    final unitIdFromRoute = Uri.base.queryParameters['unitId'];
    if (unitIdFromRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedUnitId = unitIdFromRoute;
        });
        _updateAvailableBranches(unitIdFromRoute);
      });
    }
  }

  void _updateAvailableBranches(String? unitId) {
    if (unitId == null) {
      setState(() {
        _availableBranchIds.clear();
        _selectedBranchId = null;
      });
      return;
    }

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final unit = adminProvider.units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => throw Exception('Unit not found'),
    );

    setState(() {
      _availableBranchIds.clear();
      _availableBranchIds.addAll(unit.branchIds);
      // Réinitialiser la branche sélectionnée si elle n'est plus disponible
      if (_selectedBranchId != null &&
          !_availableBranchIds.contains(_selectedBranchId)) {
        _selectedBranchId = null;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveUser() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
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

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une branche'),
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de naissance'),
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final success = await adminProvider.addUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _selectedDate!,
      role: _selectedRole,
      unitId: _selectedUnitId!,
      branchId: _selectedBranchId!,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur créé avec succès'),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Erreur lors de la création'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel utilisateur'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le prénom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le numéro de téléphone est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de naissance',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rôle',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Administrateur'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.unitLeader,
                        child: Text('Chef d\'unité'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.assistantLeader,
                        child: Text('Assistant CU'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                        if (value != UserRole.assistantLeader) {
                          _selectedBranchId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final currentUser = authProvider.currentUser;
                      final availableUnits = currentUser != null
                          ? provider.units
                              .where((u) => u.groupId == currentUser.unitId)
                              .toList()
                          : provider.units;

                      return DropdownButtonFormField<String>(
                        value: _selectedUnitId,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: availableUnits.map((unit) {
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
                      );
                    },
                  ),
                  if (_selectedRole == UserRole.assistantLeader) ...[
                    const SizedBox(height: 16),
                    if (_availableBranchIds.isEmpty && _selectedUnitId != null)
                      const Text(
                        'Aucune branche disponible pour cette unité',
                        style: TextStyle(color: Colors.orange),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedBranchId,
                        decoration: const InputDecoration(
                          labelText: 'Branche',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableBranchIds.map((branchId) {
                          final branch = DefaultBranches.getBranchById(branchId);
                          return DropdownMenuItem<String>(
                            value: branchId,
                            child: Text(branch?.name ?? branchId),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBranchId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une branche';
                          }
                          return null;
                        },
                      ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Créer'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
