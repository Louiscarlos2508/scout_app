import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/user.dart';

/// Écran pour compléter les informations après connexion Google.
class CompleteGoogleInfoScreen extends StatefulWidget {
  const CompleteGoogleInfoScreen({super.key});

  @override
  State<CompleteGoogleInfoScreen> createState() => _CompleteGoogleInfoScreenState();
}

class _CompleteGoogleInfoScreenState extends State<CompleteGoogleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedUnitId;
  String? _selectedBranchId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    // Pré-remplir avec les informations existantes de l'utilisateur
    final user = authProvider.currentUser;
    if (user != null) {
      // Pré-remplir le prénom et le nom
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      
      // Pré-remplir le téléphone si disponible
      if (user.phoneNumber.isNotEmpty) {
        _phoneController.text = user.phoneNumber;
      }
      
      // Pré-remplir la date de naissance
      _selectedDate = user.dateOfBirth;
      
      // Pré-remplir l'unité et la branche si disponibles
      if (user.unitId.isNotEmpty) {
        // Charger les units d'abord si nécessaire
        if (adminProvider.units.isEmpty) {
          adminProvider.loadUnits().then((_) {
            // Attendre un peu pour que les units soient chargées
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _prefillUnitAndBranch(user, adminProvider);
              }
            });
          });
        } else {
          // Les units sont déjà chargées, pré-remplir immédiatement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _prefillUnitAndBranch(user, adminProvider);
            }
          });
        }
      }
    }

    // Charger les units si nécessaire (pour le dropdown)
    if (adminProvider.units.isEmpty) {
      adminProvider.loadUnits();
    }
  }

  /// Pré-remplit l'unité et la branche avec les données de l'utilisateur.
  void _prefillUnitAndBranch(User user, AdminProvider adminProvider) {
    if (user.unitId.isEmpty || adminProvider.units.isEmpty) {
      return;
    }

    // Vérifier que l'unité existe dans la liste
    final unitExists = adminProvider.units.any((u) => u.id == user.unitId);
    if (unitExists) {
      setState(() {
        _selectedUnitId = user.unitId;
        
        // Pré-remplir la branche si disponible et valide pour l'unité
        if (user.branchId.isNotEmpty) {
          try {
            final unit = adminProvider.units.firstWhere(
              (u) => u.id == user.unitId,
            );
            if (unit.branchIds.contains(user.branchId)) {
              _selectedBranchId = user.branchId;
            }
          } catch (e) {
            // Si l'unité n'est pas trouvée, ne pas pré-remplir la branche
          }
        }
      });
    }
  }

  @override
  void dispose() {
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

  void _updateAvailableBranches(String? unitId) {
    if (unitId == null) {
      setState(() {
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
      if (!unit.branchIds.contains(_selectedBranchId)) {
        _selectedBranchId = null;
      }
    });
  }

  Future<void> _completeInfo() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
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

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une branche'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: utilisateur non trouvé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await authProvider.completeGoogleUserInfo(
      userId: user.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _selectedDate!,
      unitId: _selectedUnitId!,
      branchId: _selectedBranchId!,
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
        // Rediriger selon le rôle : admins vers /admin, autres vers /waiting-approval
        if (user.hasAdminAccess) {
          context.go('/admin');
        } else {
        context.go('/waiting-approval');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Compléter votre profil',
          style: TextStyle(color: Color(0xFF314158)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informations requises',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF314158),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez compléter les informations ci-dessous pour finaliser votre inscription',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 32),
                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prénom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Nom
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Téléphone
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
                // Date de naissance
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
                // Unité
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedUnitId,
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business_outlined),
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
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Branche
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (_selectedUnitId == null) {
                      return const SizedBox.shrink();
                    }

                    final unit = adminProvider.units.firstWhere(
                      (u) => u.id == _selectedUnitId,
                      orElse: () => throw Exception('Unit not found'),
                    );

                    return DropdownButtonFormField<String>(
                      value: _selectedBranchId,
                      decoration: const InputDecoration(
                        labelText: 'Branche',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      items: unit.branchIds.map((branchId) {
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
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Bouton de validation
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF314158),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continuer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
