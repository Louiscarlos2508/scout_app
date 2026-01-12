import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/group.dart';
import '../../providers/admin_provider.dart';

/// Écran de formulaire pour créer/modifier un groupe.
class GroupFormScreen extends StatefulWidget {
  final String? groupId; // null si création, défini si modification

  const GroupFormScreen({
    super.key,
    this.groupId,
  });

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _loadGroup();
    }
  }

  void _loadGroup() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final group = adminProvider.groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => throw Exception('Group not found'),
    );

    _nameController.text = group.name;
    _descriptionController.text = group.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final group = Group(
      id: widget.groupId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      unitIds: const [],
    );

    final success = widget.groupId == null
        ? await adminProvider.addGroup(group)
        : await adminProvider.modifyGroup(group);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.groupId == null
                ? 'Groupe créé avec succès'
                : 'Groupe mis à jour avec succès',
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
        title: Text(widget.groupId == null ? 'Nouveau groupe' : 'Modifier groupe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du groupe',
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGroup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.groupId == null ? 'Créer' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
