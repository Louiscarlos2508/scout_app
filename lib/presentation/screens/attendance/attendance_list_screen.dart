import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/user.dart';
import '../../../core/data/default_branches.dart';
import '../../../core/utils/date_formatter.dart';

/// Écran affichant la liste des sessions de présence d'une branche.
/// 
/// Design basé sur Figma: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=75-389
class AttendanceListScreen extends StatefulWidget {
  final String? branchId;

  const AttendanceListScreen({
    super.key,
    this.branchId,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  String? _selectedBranchId;
  String? _selectedUnitId; // Unité sélectionnée pour consulter les sessions
  final Map<String, List<Attendance>> _sessionsByBranch = {}; // Cache des sessions par branche
  bool _isFilterExpanded = false; // État pour l'expansion/réduction de la carte de filtre

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId;
    _loadSessions();
  }

  void _loadSessions() async {
    if (_selectedBranchId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
        final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        
        // Charger les unités si nécessaire
        if (adminProvider.units.isEmpty) {
          await adminProvider.loadUnits();
        }
        
        // Charger les sessions de la branche sélectionnée
        await attendanceProvider.loadSessionsByBranch(_selectedBranchId!);
        _sessionsByBranch[_selectedBranchId!] = List.from(attendanceProvider.sessions);
        
        // Si une unité est sélectionnée, charger aussi les sessions des autres branches de cette unité
        if (_selectedUnitId != null) {
          try {
            final unit = adminProvider.units.firstWhere(
              (u) => u.id == _selectedUnitId,
            );
            
            // Charger les sessions de toutes les branches de l'unité
            for (final branchId in unit.branchIds) {
              if (branchId != _selectedBranchId && !_sessionsByBranch.containsKey(branchId)) {
                await attendanceProvider.loadSessionsByBranch(branchId);
                _sessionsByBranch[branchId] = List.from(attendanceProvider.sessions);
              }
            }
          } catch (e) {
            // L'unité n'a pas été trouvée, ignorer
          }
        }
        
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Vérifie si l'utilisateur peut modifier/créer des sessions pour l'unité sélectionnée
  bool _canModifySessions(User user, String? selectedUnitId) {
    if (selectedUnitId == null) {
      // Si aucune unité n'est sélectionnée, utiliser l'unité de l'utilisateur
      return true;
    }
    // L'utilisateur peut modifier seulement s'il appartient à l'unité sélectionnée
    return user.unitId == selectedUnitId;
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

  Color _getBranchColor(String branchId) {
    final branch = DefaultBranches.getBranchById(branchId);
    if (branch != null) {
      final colorString = branch.color.replaceFirst('#', '');
      return Color(int.parse('FF$colorString', radix: 16));
    }
    return const Color(0xFFFCD34D); // Jaune par défaut (Louveteaux)
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

  /// Filtre les sessions selon l'unité sélectionnée
  /// Retourne toutes les sessions de toutes les branches de l'unité, filtrées par la branche sélectionnée
  List<Attendance> _filterSessionsByUnit(
    String? selectedUnitId,
    AdminProvider adminProvider,
  ) {
    if (selectedUnitId == null) {
      // Si aucune unité n'est sélectionnée, retourner les sessions de la branche sélectionnée
      return _sessionsByBranch[_selectedBranchId] ?? [];
    }

    // Trouver l'unité sélectionnée
    try {
      final unit = adminProvider.units.firstWhere(
        (u) => u.id == selectedUnitId,
      );

      // Récupérer toutes les sessions de toutes les branches de l'unité
      final allSessions = <Attendance>[];
      for (final branchId in unit.branchIds) {
        final sessions = _sessionsByBranch[branchId];
        if (sessions != null) {
          allSessions.addAll(sessions);
        }
      }

      // Filtrer par la branche sélectionnée si une branche est sélectionnée
      if (_selectedBranchId != null) {
        return allSessions.where((session) {
          return session.branchId == _selectedBranchId;
        }).toList();
      }

      return allSessions;
    } catch (e) {
      // Si l'unité n'est pas trouvée, retourner les sessions de la branche sélectionnée
      return _sessionsByBranch[_selectedBranchId] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<AttendanceProvider, BranchProvider, AuthProvider, AdminProvider>(
      builder: (context, attendanceProvider, branchProvider, authProvider, adminProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Center(child: Text('Aucun utilisateur connecté'));
        }
        
        // Charger les unités si nécessaire
        if (adminProvider.units.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            adminProvider.loadUnits();
          });
        }

        // Normaliser le branchId si nécessaire
        final normalizedBranchId = _selectedBranchId != null
            ? DefaultBranches.normalizeBranchId(_selectedBranchId!)
            : null;

        // Récupérer la branche
        Branch? branch;
        if (normalizedBranchId != null) {
          branch = branchProvider.getBranchById(normalizedBranchId) ??
              DefaultBranches.getBranchById(normalizedBranchId);
        }

        if (branch == null && normalizedBranchId != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Branche non trouvée: $normalizedBranchId',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ],
              ),
            ),
          );
        }

        if (branch == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final nonNullBranch = branch;
        final branchColor = _getBranchColor(nonNullBranch.id);

        // Initialiser l'unité sélectionnée avec l'unité de l'utilisateur si pas encore défini
        if (_selectedUnitId == null) {
          _selectedUnitId = user.unitId;
        }

        // Filtrer les sessions selon l'unité sélectionnée
        final filteredSessions = _filterSessionsByUnit(
          _selectedUnitId,
          adminProvider,
        );

        // Vérifier si l'utilisateur peut modifier/créer des sessions
        final canModify = _canModifySessions(user, _selectedUnitId);

        // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
        return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Stack(
              children: [
                // Structure principale : Column avec header et liste
                Column(
                  children: [
                  // Header avec gradient de la couleur de la branche
                  _buildHeader(
                    nonNullBranch,
                    branchColor,
                    user,
                    attendanceProvider,
                    adminProvider,
                    _selectedUnitId,
                    (unitId) {
                      setState(() {
                        _selectedUnitId = unitId;
                      });
                      // Recharger les sessions pour la nouvelle unité
                      _loadSessions();
                    },
                  ),
                  // Liste des sessions (prend toute la hauteur restante)
                  Expanded(
                    child: _buildSessionsList(
                      filteredSessions,
                      branchColor,
                      canModify,
                      _isFilterExpanded,
                    ),
                  ),
                ],
              ),
              // Container avec sélecteur d'unité et bouton (chevauche le header)
              Positioned(
                top: 275,
                left: 24,
                right: 24,
                child: _buildUnitSelector(
                  nonNullBranch,
                  _selectedUnitId,
                  (unitId) {
                    setState(() {
                      _selectedUnitId = unitId;
                    });
                    // Recharger les sessions pour la nouvelle unité
                    _loadSessions();
                  },
                  adminProvider,
                  user,
                  branchColor,
                  canModify,
                  _isFilterExpanded,
                  () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                ),
              ),
              ],
            ),
        );
      },
    );
  }

  /// Header avec gradient de la couleur de la branche
  Widget _buildHeader(
    Branch branch,
    Color branchColor,
    User user,
    AttendanceProvider provider,
    AdminProvider adminProvider,
    String? selectedUnitId,
    ValueChanged<String?> onUnitChanged,
  ) {
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
      height: 327.993,
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
                  onTap: () => context.go('/home'),
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
              // Titre "Gestion des présences"
              const Text(
                'Gestion des présences',
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
              const SizedBox(height: 12),
              // Carte avec nombre de sessions
              Consumer<AttendanceProvider>(
                builder: (context, provider, child) {
                  // Filtrer les sessions selon l'unité sélectionnée
                  final filteredSessions = _filterSessionsByUnit(
                    selectedUnitId,
                    adminProvider,
                  );
                  final totalSessions = filteredSessions.length;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalSessions.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Session${totalSessions > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sélecteur d'unité pour consulter les sessions d'autres unités
  Widget _buildUnitSelector(
    Branch branch,
    String? selectedUnitId,
    ValueChanged<String?> onUnitChanged,
    AdminProvider adminProvider,
    User user,
    Color branchColor,
    bool canModify,
    bool isExpanded,
    VoidCallback onToggleExpanded,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row avec bouton "Créer une nouvelle session" et bouton "Filtre"
          Row(
            children: [
              // Bouton "Créer une nouvelle session"
              Expanded(
                child: InkWell(
                  onTap: canModify
                      ? () => context.go(
                            '/attendance/new?branchId=${Uri.encodeComponent(_selectedBranchId ?? '')}',
                          )
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vous ne pouvez pas créer de session pour une unité dont vous ne faites pas partie',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 47.999,
                    decoration: BoxDecoration(
                      gradient: canModify
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF45556C), Color(0xFF314158)],
                            )
                          : null,
                      color: canModify ? null : const Color(0xFF9CA3AF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: canModify
                          ? [
                              BoxShadow(
                                color: const Color(0xFF62748E).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: const Color(0xFF62748E).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, -4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                          color: canModify ? Colors.white : Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Créer une nouvelle session',
                          style: TextStyle(
                            fontSize: 16,
                            color: canModify ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton "Filtre"
              InkWell(
                onTap: onToggleExpanded,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filtre',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF155DFC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: const Color(0xFF155DFC),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sélecteur d'unité (affiché/masqué selon l'état)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.group,
                            size: 18.876,
                            color: Color(0xFF101828),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Voir les sessions dans d\'autres unités',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unité (Branche : ${branch.name})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF364153),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUnitId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.219,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
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
                            vertical: 14,
                          ),
                        ),
                        items: adminProvider.units
                            .where((unit) => unit.branchIds.contains(branch.id))
                            .map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit.id,
                            child: Text(unit.name),
                          );
                        }).toList(),
                        onChanged: onUnitChanged,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous consultez les sessions de la branche ${branch.name} (${branch.ageRange})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Bouton "Créer une nouvelle session"
  Widget _buildCreateSessionButton(Color branchColor, bool canModify) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: InkWell(
        onTap: canModify
            ? () => context.go(
                  '/attendance/new?branchId=${Uri.encodeComponent(_selectedBranchId ?? '')}',
                )
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Vous ne pouvez pas créer de session pour une unité dont vous ne faites pas partie',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 47.999,
          decoration: BoxDecoration(
            gradient: canModify
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF45556C), Color(0xFF314158)],
                  )
                : null,
            color: canModify ? null : const Color(0xFF9CA3AF),
            borderRadius: BorderRadius.circular(10),
            boxShadow: canModify
                ? [
                    BoxShadow(
                      color: const Color(0xFF62748E).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: const Color(0xFF62748E).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 20,
                color: canModify ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'Créer une nouvelle session',
                style: TextStyle(
                  fontSize: 16,
                  color: canModify ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Liste des sessions
  Widget _buildSessionsList(
    List<Attendance> sessions,
    Color branchColor,
    bool canModify,
    bool isFilterExpanded,
  ) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune session de présence',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              canModify
                  ? 'Créez une nouvelle session pour commencer'
                  : 'Aucune session disponible pour cette unité',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Calculer le padding nécessaire pour que la liste commence après la carte
    // La carte commence à 275px depuis le haut de l'écran
    // Hauteur approximative de la carte réduite : padding (16*2=32) + bouton (47.999) = environ 80px
    // Hauteur approximative de la carte étendue : padding (16*2=32) + bouton (47.999) + gap (16) + header sélecteur (54) + gap (16) + label (20) + gap (8) + dropdown (48) + gap (8) + texte (32) = environ 280px
    final double containerTop = 275;
    final double unitSelectorHeight = isFilterExpanded ? 280 : 80; // Hauteur selon l'état (réduit ou étendu)
    final double containerBottom = containerTop + unitSelectorHeight;
    final double headerHeight = 327.993;
    // Le padding doit être calculé depuis le bas du header
    final double topPadding = containerBottom - headerHeight + 24;

    return ListView.separated(
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding : 12,
        left: 24,
        right: 24,
        bottom: 12,
      ),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session, canModify);
      },
    );
  }

  /// Carte d'une session selon le design Figma
  Widget _buildSessionCard(Attendance session, bool canModify) {
    final presentCount = session.presentMemberIds.length;
    final absentCount = session.absentMemberIds.length;
    final totalCount = presentCount + absentCount;
    final presentPercentage = totalCount > 0 ? (presentCount / totalCount) : 0.0;

    return InkWell(
      onTap: canModify
          ? () => context.go('/attendance/${session.id}')
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Vous ne pouvez pas modifier les sessions d\'une unité dont vous ne faites pas partie',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canModify ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFF3F4F6),
              width: 1.219,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la session avec icône dropdown et badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getSessionTypeName(session.type),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF0A0A0A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color(0xFF6A7282),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatDateLong(session.date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge du type de session
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getSessionTypeLabel(session.type),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF364153),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats : présents, absents, pourcentage
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C950),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$presentCount présent${presentCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFB2C36),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$absentCount absent${absentCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(presentPercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF364153),
                    ),
                  ),
                ],
            ),
            const SizedBox(height: 16),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: presentPercentage,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  presentPercentage >= 0.8
                      ? const Color(0xFF00C950)
                      : presentPercentage >= 0.5
                          ? const Color(0xFFFFA500)
                          : const Color(0xFFFB2C36),
                ),
                minHeight: 8,
          ),
        ),
      ],
        ),
      ),
    );
  }
}
