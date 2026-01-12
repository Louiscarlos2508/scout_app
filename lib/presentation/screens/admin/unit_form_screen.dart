import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/unit.dart';
import '../../../core/data/default_branches.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

/// Écran de formulaire pour créer/modifier une unité.
class UnitFormScreen extends StatefulWidget {
  final String? unitId; // null si création, défini si modification

  const UnitFormScreen({
    super.key,
    this.unitId,
  });

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<String> _selectedBranchIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.unitId != null) {
      _loadUnit();
    }
  }

  void _loadUnit() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final unit = adminProvider.units.firstWhere(
      (u) => u.id == widget.unitId,
      orElse: () => throw Exception('Unit not found'),
    );

    _nameController.text = unit.name;
    _selectedBranchIds.addAll(unit.branchIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une branche'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null || !currentUser.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: utilisateur non autorisé'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final unit = Unit(
      id: widget.unitId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      groupId: currentUser.unitId, // Utiliser le groupe de l'admin
      branchIds: _selectedBranchIds.toList(),
    );

    final success = widget.unitId == null
        ? await adminProvider.addUnit(unit)
        : await adminProvider.modifyUnit(unit);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.unitId == null
                ? 'Unité créée avec succès'
                : 'Unité mise à jour avec succès',
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitId == null ? 'Nouvelle unité' : 'Modifier unité'),
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'unité',
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
                  const Text(
                    'Branches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...DefaultBranches.allBranches.map((branch) {
                    return CheckboxListTile(
                      title: Text(branch.name),
                      subtitle: Text('${branch.minAge}-${branch.maxAge} ans'),
                      value: _selectedBranchIds.contains(branch.id),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedBranchIds.add(branch.id);
                          } else {
                            _selectedBranchIds.remove(branch.id);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveUnit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.unitId == null ? 'Créer' : 'Enregistrer'),
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
