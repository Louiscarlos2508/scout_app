import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/user.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/attendance/attendance_toggle.dart';
import '../../theme/app_colors.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/utils/date_formatter.dart';

/// Écran de pointage de présence pour une session.
class AttendanceSessionScreen extends StatefulWidget {
  final String sessionId;

  const AttendanceSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<AttendanceSessionScreen> createState() => _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState extends State<AttendanceSessionScreen> {
  Attendance? _session;
  List<Member> _members = [];
  bool _isLoading = true;
  bool _canModify = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Vérifie si l'utilisateur peut modifier la session
  bool _canModifySession(User user, Attendance session, AdminProvider adminProvider) {
    // Trouver l'unité de l'utilisateur
    try {
      final unit = adminProvider.units.firstWhere(
        (u) => u.id == user.unitId,
      );
      // Vérifier si la branche de la session appartient à l'unité de l'utilisateur
      return unit.branchIds.contains(session.branchId);
    } catch (e) {
      // Si l'unité n'est pas trouvée, ne pas autoriser la modification
      return false;
    }
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      try {
        // Charger les unités si nécessaire
        if (adminProvider.units.isEmpty) {
          await adminProvider.loadUnits();
        }

        // Charger toutes les sessions pour trouver celle demandée
        // (En production, on chargerait directement par ID)
        // On charge d'abord toutes les branches pour trouver la bonne session
        final branches = ['louveteaux', 'eclaireurs', 'sinikie', 'routiers'];
        Attendance? foundSession;
        
        for (final branchId in branches) {
          await attendanceProvider.loadSessionsByBranch(branchId);
          try {
            foundSession = attendanceProvider.sessions.firstWhere(
              (s) => s.id == widget.sessionId,
            );
            break;
          } catch (e) {
            // Continue à chercher dans les autres branches
          }
        }

        if (foundSession == null) {
          throw Exception('Session not found');
        }

        _session = foundSession;

        // Charger les membres de la branche
        await memberProvider.loadMembersByBranch(_session!.branchId);
        _members = memberProvider.members;

        // Vérifier si l'utilisateur peut modifier la session
        final user = authProvider.currentUser;
        if (user != null) {
          _canModify = _canModifySession(user, _session!, adminProvider);
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _toggleAttendance(String memberId, bool isPresent) async {
    if (!_canModify) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez pas modifier les sessions d\'une unité dont vous ne faites pas partie',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final success = await provider.toggleMemberAttendance(
      widget.sessionId,
      memberId,
      isPresent,
    );

    if (!mounted) return;

    if (success) {
      // Mettre à jour la session locale
      setState(() {
        _session = provider.sessions.firstWhere(
          (s) => s.id == widget.sessionId,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
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

  String _getSessionTypeName(SessionType type) {
    switch (type) {
      case SessionType.weekly:
        return 'Rencontre hebdomadaire';
      case SessionType.monthly:
        return 'Rencontre mensuelle';
      case SessionType.special:
        return 'Activité spéciale';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Session non trouvée')),
      );
    }

    final presentCount = _session!.presentMemberIds.length;
    final absentCount = _session!.absentMemberIds.length;
    final totalCount = _members.length;
    final presentPercentage = totalCount > 0 ? (presentCount / totalCount) : 0.0;

    // Trier les membres : présents d'abord, puis absents, puis non marqués
    final presentMembers = _members.where((m) => _session!.presentMemberIds.contains(m.id)).toList();
    final absentMembers = _members.where((m) => _session!.absentMemberIds.contains(m.id)).toList();
    final unmarkedMembers = _members.where((m) => 
      !_session!.presentMemberIds.contains(m.id) && 
      !_session!.absentMemberIds.contains(m.id)
    ).toList();

    return Consumer3<BranchProvider, AuthProvider, AdminProvider>(
      builder: (context, branchProvider, authProvider, adminProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Aucun utilisateur connecté')),
          );
        }

        // Récupérer la branche
        final normalizedBranchId = DefaultBranches.normalizeBranchId(_session!.branchId);
        final branch = branchProvider.getBranchById(normalizedBranchId) ??
            DefaultBranches.getBranchById(normalizedBranchId) ??
            Branch(
              id: normalizedBranchId,
              name: 'Branche',
              color: '#FCD34D',
              minAge: 0,
              maxAge: 18,
            );

        final branchColor = _getBranchColor(_session!.branchId);

        // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              // Header avec gradient de la couleur de la branche
              _buildHeader(context, branch, branchColor, _session!),
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatChip('Présents', presentCount, AppColors.success),
                          _buildStatChip('Absents', absentCount, AppColors.error),
                          _buildStatChip('Total', totalCount, AppColors.primary),
                        ],
                      ),
                      if (totalCount > 0) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: presentPercentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              presentPercentage >= 0.8
                                  ? AppColors.success
                                  : presentPercentage >= 0.5
                                      ? AppColors.warning
                                      : AppColors.error,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(presentPercentage * 100).toStringAsFixed(0)}% de présence',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!_canModify) ...[
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vous consultez une session d\'une autre unité. Vous ne pouvez pas la modifier.',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (presentMembers.isNotEmpty) ...[
                        _buildSectionHeader('Présents (${presentMembers.length})', AppColors.success),
                        ...presentMembers.map((member) => AttendanceToggle(
                          memberName: member.fullName,
                          isPresent: true,
                          onToggle: _canModify ? () => _toggleAttendance(member.id, false) : null,
                          enabled: _canModify,
                        )),
                      ],
                      if (absentMembers.isNotEmpty) ...[
                        _buildSectionHeader('Absents (${absentMembers.length})', AppColors.error),
                        ...absentMembers.map((member) => AttendanceToggle(
                          memberName: member.fullName,
                          isPresent: false,
                          onToggle: _canModify ? () => _toggleAttendance(member.id, true) : null,
                          enabled: _canModify,
                        )),
                      ],
                      if (unmarkedMembers.isNotEmpty) ...[
                        _buildSectionHeader('Non marqués (${unmarkedMembers.length})', Colors.grey),
                        ...unmarkedMembers.map((member) => AttendanceToggle(
                          memberName: member.fullName,
                          isPresent: false,
                          onToggle: _canModify ? () => _toggleAttendance(member.id, true) : null,
                          enabled: _canModify,
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Header avec gradient de la couleur de la branche
  Widget _buildHeader(BuildContext context, Branch branch, Color branchColor, Attendance session) {
    final gradientColors = [
      branchColor,
      branchColor.withOpacity(0.867),
    ];

    // Angle du gradient selon Figma: 145.68646484219155deg
    const double angleDeg = 145.68646484219155;
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
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.go(
                    '/attendance?branchId=${Uri.encodeComponent(session.branchId)}',
                  ),
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
              ),
              const SizedBox(height: 16),
              // Titre
              Text(
                _getSessionTypeName(session.type),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Date
              Text(
                DateFormatter.formatDateLong(session.date),
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

  Widget _buildStatChip(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

