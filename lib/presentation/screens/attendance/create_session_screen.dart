import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/branch.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/branch_provider.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/utils/validators.dart';

/// Écran de création d'une nouvelle session de présence.
/// Design basé sur Figma: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=81-1068
class CreateSessionScreen extends StatefulWidget {
  final String? branchId;

  const CreateSessionScreen({
    super.key,
    this.branchId,
  });

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  SessionType _selectedType = SessionType.weekly;
  String _selectedBranchId = 'louveteaux';
  bool _isLoading = false;
  List<Member> _members = [];
  final Set<String> _presentMemberIds = {};
  final Set<String> _absentMemberIds = {};

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId ?? 'louveteaux';
    _selectedDate = DateTime.now();
    _loadMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _loadMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false)
          .loadMembersByBranch(_selectedBranchId);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getSessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.weekly:
        return 'Hebdomadaire';
      case SessionType.monthly:
        return 'Mensuelle';
      case SessionType.special:
        return 'Activité spéciale';
    }
  }

  Color _getBranchColor(String branchId) {
    final branch = DefaultBranches.getBranchById(branchId);
    if (branch != null) {
      final colorString = branch.color.replaceFirst('#', '');
      return Color(int.parse('FF$colorString', radix: 16));
    }
    return const Color(0xFFFCD34D); // Jaune par défaut (Louveteaux)
  }

  String _getUnitDisplayName(String unitId, AdminProvider adminProvider) {
    try {
      final unit = adminProvider.units.firstWhere(
        (u) => u.id == unitId,
      );
      return unit.name;
    } catch (e) {
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

  /// Vérifie si l'utilisateur peut créer une session pour la branche sélectionnée
  bool _canCreateSessionForBranch(User user, String branchId, AdminProvider adminProvider) {
    try {
      final unit = adminProvider.units.firstWhere(
        (u) => u.id == user.unitId,
      );
      return unit.branchIds.contains(branchId);
    } catch (e) {
      return false;
    }
  }

  void _markAllPresent() {
    setState(() {
      _presentMemberIds.clear();
      _absentMemberIds.clear();
      for (final member in _members) {
        _presentMemberIds.add(member.id);
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      _presentMemberIds.clear();
      _absentMemberIds.clear();
      for (final member in _members) {
        _absentMemberIds.add(member.id);
      }
    });
  }

  void _toggleMemberAttendance(String memberId) {
    setState(() {
      if (_presentMemberIds.contains(memberId)) {
        _presentMemberIds.remove(memberId);
        _absentMemberIds.add(memberId);
      } else if (_absentMemberIds.contains(memberId)) {
        _absentMemberIds.remove(memberId);
        _presentMemberIds.add(memberId);
      } else {
        // Par défaut, marquer comme absent
        _absentMemberIds.add(memberId);
      }
    });
  }

  String _getMemberStatus(String memberId) {
    if (_presentMemberIds.contains(memberId)) {
      return 'Présent';
    } else if (_absentMemberIds.contains(memberId)) {
      return 'Absent';
    }
    return 'Absent'; // Par défaut absent
  }

  Color _getMemberStatusColor(String memberId) {
    if (_presentMemberIds.contains(memberId)) {
      return const Color(0xFF00C950); // Vert
    }
    return const Color(0xFFFB2C36); // Rouge
  }

  String _getMemberInitials(Member member) {
    final firstName = member.firstName.isNotEmpty ? member.firstName[0] : '';
    final lastName = member.lastName.isNotEmpty ? member.lastName[0] : '';
    return '${firstName.toUpperCase()}${lastName.toUpperCase()}';
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun utilisateur connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_canCreateSessionForBranch(user, _selectedBranchId, adminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez pas créer de session pour une branche qui n\'appartient pas à votre unité',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final session = Attendance(
      id: '', // Sera généré par le repository
      date: _selectedDate!,
      type: _selectedType,
      branchId: _selectedBranchId,
      presentMemberIds: _presentMemberIds.toList(),
      absentMemberIds: _absentMemberIds.toList(),
    );

    final success = await provider.addSession(session);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/attendance/${provider.sessions.last.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la création'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader(Branch branch, Color branchColor, User user, AdminProvider adminProvider) {
    final gradientColors = [
      branchColor,
      branchColor.withOpacity(0.867),
    ];

    const double angleDeg = 159.4779148486323;
    final double angleRad = angleDeg * math.pi / 180;
    final double cosAngle = math.cos(angleRad);
    final double sinAngle = math.sin(angleRad);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-cosAngle, -sinAngle),
          end: Alignment(cosAngle, sinAngle),
          colors: gradientColors,
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton retour
              InkWell(
                onTap: () {
                  final branchIdParam = _selectedBranchId != null
                      ? '?branchId=${Uri.encodeComponent(_selectedBranchId)}'
                      : '';
                  context.go('/attendance$branchIdParam');
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Colors.white,
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
              const SizedBox(height: 16),
              // Titre "Nouvelle session"
              const Text(
                'Nouvelle session',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Sous-titre "Louveteaux • Unité Alpha"
              Text(
                '${branch.name} • ${_getUnitDisplayName(user.unitId, adminProvider)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<AuthProvider, AdminProvider, BranchProvider, MemberProvider>(
      builder: (context, authProvider, adminProvider, branchProvider, memberProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Aucun utilisateur connecté')),
          );
        }

        // Charger les unités si nécessaire
        if (adminProvider.units.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            adminProvider.loadUnits();
          });
        }

        // Charger les membres si nécessaire
        if (memberProvider.members.isEmpty && !memberProvider.isLoading) {
          _loadMembers();
        }
        _members = memberProvider.members.where((m) => m.branchId == _selectedBranchId).toList();

        // Normaliser le branchId
        final normalizedBranchId = DefaultBranches.normalizeBranchId(_selectedBranchId);
        final branch = branchProvider.getBranchById(normalizedBranchId) ??
            DefaultBranches.getBranchById(normalizedBranchId);

        if (branch == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final branchColor = _getBranchColor(branch.id);
        final canCreate = _canCreateSessionForBranch(user, _selectedBranchId, adminProvider);

        final presentCount = _presentMemberIds.length;
        final absentCount = _absentMemberIds.length;
        final totalCount = _members.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              // Header avec gradient
              _buildHeader(branch, branchColor, user, adminProvider),
              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section "Informations de la session"
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations de la session',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF0A0A0A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Champ Titre
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Titre',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF364153),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFB2C36),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      hintText: 'Ex: Rencontre hebdomadaire, Camp d\'été...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD1D5DC),
                                          width: 1.219,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD1D5DC),
                                          width: 1.219,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF155DFC),
                                          width: 1.219,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Le titre est requis';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Champ Date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF364153),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFB2C36),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      height: 42.437,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DC),
                                          width: 1.219,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _selectedDate != null
                                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                                  : 'Sélectionner une date',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _selectedDate != null
                                                    ? const Color(0xFF0A0A0A)
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: Color(0xFF364153),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Champ Type de session
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Type de session',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF364153),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFB2C36),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<SessionType>(
                                    value: _selectedType,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD1D5DC),
                                          width: 1.219,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD1D5DC),
                                          width: 1.219,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF155DFC),
                                          width: 1.219,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: SessionType.values.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(_getSessionTypeLabel(type)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section "Actions rapides"
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Actions rapides',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF0A0A0A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _markAllPresent,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Tous présents',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF008236),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _markAllAbsent,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Tous absents',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF364153),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section "Pointage"
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pointage (${totalCount} membre${totalCount > 1 ? 's' : ''})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF0A0A0A),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF00C950),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$presentCount',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF4A5565),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFB2C36),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$absentCount',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF4A5565),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Liste des membres
                              ..._members.map((member) {
                                final status = _getMemberStatus(member.id);
                                final statusColor = _getMemberStatusColor(member.id);
                                final isPresent = _presentMemberIds.contains(member.id);

                                return InkWell(
                                  onTap: () => _toggleMemberAttendance(member.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: branchColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getMemberInitials(member),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              member.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF0A0A0A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isPresent
                                                ? const Color(0xFFF0FDF4)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isPresent
                                                  ? const Color(0xFF008236)
                                                  : const Color(0xFF4A5565),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Boutons Annuler et Créer
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  final branchIdParam = _selectedBranchId != null
                                      ? '?branchId=${Uri.encodeComponent(_selectedBranchId)}'
                                      : '';
                                  context.go('/attendance$branchIdParam');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(
                                    color: Color(0xFFD1D5DC),
                                    width: 1.219,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (_isLoading || !canCreate) ? null : _createSession,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF155DFC),
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
                                        'Créer la session',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
