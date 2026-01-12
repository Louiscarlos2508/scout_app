import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/attendance.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/data/default_branches.dart';
import '../../../main.dart' as main_app;

/// Écran d'accueil principal de l'application.
/// Design basé sur Figma:
/// - Chef d'unité: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=37-79
/// - Assistant: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=37-311
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Cache local pour stocker toutes les données (car les providers remplacent au lieu d'accumuler)
  final Map<String, List<Member>> _membersByBranch = {};
  final Map<String, List<Attendance>> _sessionsByBranch = {};
  
  // Pour gérer le double appui sur retour pour quitter l'app
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    // Retarder le chargement après le premier frame pour éviter setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupDataListeners();
    });
  }

  /// Configure les listeners pour recharger les données quand elles changent.
  void _setupDataListeners() {
    // Écouter les changements de synchronisation pour recharger les données
    final syncService = main_app.syncService;
    
    if (syncService == null) return;

    // Écouter les notifications de synchronisation des membres
    syncService.membersSynced.listen((_) {
      if (mounted) {
        debugPrint('🔄 Rechargement des données après synchronisation des membres');
        _loadData();
      }
    });

    // Écouter les notifications de synchronisation des sessions
    syncService.attendanceSynced.listen((_) {
      if (mounted) {
        debugPrint('🔄 Rechargement des données après synchronisation des sessions');
        _loadData();
      }
    });

    // Écouter les changements de branches
    syncService.branchesSynced.listen((_) {
      if (mounted) {
        debugPrint('🔄 Rechargement des données après synchronisation des branches');
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final branchProvider = Provider.of<BranchProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) return;

    // Charger toutes les branches depuis le cache local (Drift)
    await branchProvider.loadAllBranches();

    // Attendre un peu pour que les branches soient chargées si elles viennent d'être synchronisées
    if (branchProvider.branches.isEmpty && branchProvider.isLoading) {
      // Attendre que le chargement soit terminé
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Déterminer quelles branches charger selon le rôle
    List<Branch> branches;
    
    if (user.role == UserRole.unitLeader) {
      // Le chef d'unité voit toutes les branches
      branches = branchProvider.branches;
    } else if (user.role == UserRole.assistantLeader && user.branchId != null) {
      // Normaliser le branchId depuis Firestore (peut être "branch-louveteaux-1" → "louveteaux")
      final normalizedBranchId = DefaultBranches.normalizeBranchId(user.branchId!);
      
      // Le chef assistant ne voit que sa branche assignée (avec ID normalisé)
      branches = branchProvider.branches.where((b) => b.id == normalizedBranchId).toList();
      
      // Afficher un avertissement si la branche assignée n'existe pas
      if (branches.isEmpty) {
        debugPrint(
          '⚠️ ATTENTION: L\'utilisateur a branchId="${user.branchId}" (normalisé: "$normalizedBranchId") mais cette branche n\'existe pas.\n'
          'Branches disponibles: ${branchProvider.branches.map((b) => b.id).join(", ")}\n'
          'Vérifiez que le branchId dans Firestore correspond à l\'un des IDs: louveteaux, eclaireurs, sinikie, routiers',
        );
      } else {
        debugPrint(
          '✅ Branche trouvée: "${user.branchId}" → "$normalizedBranchId" → ${branches.first.name}',
        );
      }
    } else {
      // Cas où l'utilisateur n'a pas de branche assignée
      branches = [];
      debugPrint(
        '⚠️ ATTENTION: L\'utilisateur ${user.role.name} n\'a pas de branche assignée (branchId est null)',
      );
    }

    // Charger les membres et sessions pour chaque branche depuis le cache local (Drift)
    for (final branch in branches) {
      await memberProvider.loadMembersByBranch(branch.id);
      _membersByBranch[branch.id] = List.from(memberProvider.members);
      
      await attendanceProvider.loadSessionsByBranch(branch.id);
      _sessionsByBranch[branch.id] = List.from(attendanceProvider.sessions);
    }

    if (mounted) {
      setState(() {});
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
          return const Center(
            child: Text('Aucun utilisateur connecté'),
          );
        }

        // Si l'utilisateur est admin, rediriger vers l'interface admin
        if (user.hasAdminAccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/admin');
          });
          return const Center(child: CircularProgressIndicator());
        }

        // PopScope pour gérer le double appui sur retour pour quitter l'app (comportement Android standard)
        return PopScope(
          canPop: false, // On contrôle tout manuellement
          onPopInvoked: (bool didPop) {
            if (didPop) return; // Le pop s'est déjà fait, rien à faire
            
            // Si on peut naviguer en arrière dans l'historique, faire le retour normal
            if (context.canPop()) {
              context.pop();
              return;
            }
            
            // Sinon, on est sur la page racine -> implémenter le double appui pour quitter
            final now = DateTime.now();
            
            // Si c'est le premier appui ou si plus de 2 secondes se sont écoulées
            if (_lastBackPressed == null ||
                now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
              _lastBackPressed = now;
              
              // Afficher le message "Appuyez encore pour quitter"
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appuyez encore pour quitter'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            
            // 2ème appui dans les 2 secondes -> quitter l'application
            SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(user, adminProvider),
                  _buildStatsCards(user),
                  const SizedBox(height: 16),
                  _buildBranchesSection(user),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header bleu foncé avec le nom de l'utilisateur
  Widget _buildHeader(User user, AdminProvider adminProvider) {
    return Container(
      height: 340, // Hauteur fixe comme dans profil
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF45556C), // #45556C
            const Color(0xFF314158), // #314158
            const Color(0xFF1D293D), // #1D293D
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 16,
                color: Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bienvenue,',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Chef ${user.firstName}',
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.219,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            user.firstName[0].toUpperCase() +
                                (user.lastName.isNotEmpty
                                    ? user.lastName[0].toUpperCase()
                                    : ''),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
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
                    color: Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 17.219,
              bottom: 17.219,
              left: 17.219,
              right: 17.219,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.219,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unité',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE2E8F0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getUnitDisplayName(user.unitId, adminProvider),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15), // Réduit de 40 à 20 pour éviter le débordement
        ],
          ),
        ),
      ),
    );
  }

  /// Cartes de statistiques (Branches, Membres, Sessions)
  /// 
  /// Les données sont lues depuis :
  /// - Branches : BranchProvider -> BranchRepository -> BranchLocalDataSource (Drift cache)
  /// - Membres : MemberProvider -> MemberRepository -> MemberLocalDataSource (Drift cache)
  /// - Sessions : AttendanceProvider -> AttendanceRepository -> AttendanceLocalDataSource (Drift cache)
  Widget _buildStatsCards(User user) {
    return Consumer3<BranchProvider, MemberProvider, AttendanceProvider>(
      builder: (context, branchProvider, memberProvider, attendanceProvider, child) {
        // Lire les branches depuis BranchProvider (qui lit depuis Drift via Repository)
        List<Branch> branches;
        
        if (user.role == UserRole.unitLeader) {
          // Le chef d'unité voit toutes les branches
          branches = branchProvider.branches;
        } else if (user.role == UserRole.assistantLeader && user.branchId != null) {
          // Normaliser le branchId depuis Firestore
          final normalizedBranchId = DefaultBranches.normalizeBranchId(user.branchId!);
          // Le chef assistant ne voit que sa branche assignée
          branches = branchProvider.branches.where((b) => b.id == normalizedBranchId).toList();
        } else {
          // Cas où l'utilisateur n'a pas de branche assignée
          branches = [];
        }
        
        // Calculer les statistiques en comptant directement depuis les providers
        // pour chaque branche (les providers remplacent les données, donc on doit recharger pour chaque branche)
        int totalMembers = 0;
        int totalSessions = 0;
        
        // Utiliser le cache local mis à jour dans _loadData, mais aussi vérifier les providers
        // en cas de mise à jour récente
        for (final branch in branches) {
          // D'abord essayer depuis le cache local (plus performant)
          final cachedMembers = _membersByBranch[branch.id];
          final cachedSessions = _sessionsByBranch[branch.id];
          
          if (cachedMembers != null && cachedSessions != null) {
            totalMembers += cachedMembers.length;
            totalSessions += cachedSessions.length;
          } else {
            // Si le cache n'est pas disponible, compter depuis les providers
            // (mais attention: les providers ne contiennent que la dernière branche chargée)
            // Donc on préfère utiliser le cache qui accumule toutes les branches
          }
        }

        return Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            margin: const EdgeInsets.only(left: 24, right: 24),
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
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  branches.length.toString(),
                  user.role == UserRole.unitLeader ? 'Branches' : 'Branche',
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF45556C), Color(0xFF90A1B9)],
                  ),
                ),
              ),
              Container(
                width: 1.219,
                margin: const EdgeInsets.symmetric(horizontal: 1.219),
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: _buildStatCard(
                  totalMembers.toString(),
                  'Membres',
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF009966), Color(0xFF00D492)],
                  ),
                ),
              ),
              Container(
                width: 1.219,
                margin: const EdgeInsets.symmetric(horizontal: 1.219),
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: _buildStatCard(
                  totalSessions.toString(),
                  'Sessions',
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4F39F6), Color(0xFF7C86FF)],
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, Gradient gradient) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A5565),
          ),
        ),
      ],
    );
  }

  /// Section des branches
  /// 
  /// Les branches sont lues depuis :
  /// BranchProvider -> BranchRepository -> BranchLocalDataSource -> Drift (cache local)
  /// 
  /// Le BranchProvider écoute automatiquement les mises à jour de RealtimeSyncService
  /// qui synchronise les données depuis Firestore vers Drift
  Widget _buildBranchesSection(User user) {
    return Consumer<BranchProvider>(
      builder: (context, branchProvider, child) {
        // Lire les branches depuis BranchProvider (codées en dur et initialisées automatiquement)
        List<Branch> branches;
        
        if (user.role == UserRole.unitLeader) {
          // Le chef d'unité voit toutes les branches
          branches = branchProvider.branches;
        } else if (user.role == UserRole.assistantLeader && user.branchId != null) {
          // Normaliser le branchId depuis Firestore (peut être "branch-louveteaux-1" → "louveteaux")
          final normalizedBranchId = DefaultBranches.normalizeBranchId(user.branchId!);
          
          // Le chef assistant ne voit que sa branche assignée (avec ID normalisé)
          branches = branchProvider.branches.where((b) => b.id == normalizedBranchId).toList();
        } else {
          // Cas où l'utilisateur n'a pas de branche assignée (devrait être rare)
          branches = [];
        }

        if (branchProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des branches depuis le cache local...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (branches.isEmpty) {
          // Afficher des informations de débogage
          final allBranchIds = branchProvider.branches.map((b) => b.id).join(', ');
          final userBranchId = user.branchId ?? 'null';
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Color(0xFF6A7282),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune branche disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de débogage:',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rôle: ${user.role.name}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Branche assignée: $userBranchId',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Branches disponibles: $allBranchIds',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                        if (user.role == UserRole.assistantLeader && user.branchId != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'BranchId normalisé: "${DefaultBranches.normalizeBranchId(user.branchId!)}"',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6A7282),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '⚠️ La branche "$userBranchId" n\'existe pas dans la liste des branches disponibles.\n'
                              'Vérifiez que la valeur branchId dans Firestore correspond à l\'un des IDs: $allBranchIds',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadData(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.role == UserRole.unitLeader
                        ? 'Toutes les branches'
                        : 'Ma branche',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${branches.length} ${branches.length > 1 ? 'actives' : 'active'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF314158),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...branches.map((branch) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBranchCard(
                      branch,
                      _membersByBranch[branch.id] ?? [],
                      _sessionsByBranch[branch.id] ?? [],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  /// Carte d'une branche
  Widget _buildBranchCard(Branch branch, List<Member> members, List<Attendance> sessions) {
    // Convertir la couleur hexadécimale en Color
    Color branchColor;
    try {
      final colorString = branch.color.replaceFirst('#', '');
      branchColor = Color(int.parse('FF$colorString', radix: 16));
    } catch (e) {
      // Fallback vers une couleur par défaut
      branchColor = const Color(0xFF45556C);
    }
    
    final lastSession = sessions.isNotEmpty
        ? sessions.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;

    // Calculer le taux de présence
    double attendanceRate = 0.0;
    if (sessions.isNotEmpty) {
      int totalPresent = 0;
      int totalAbsent = 0;
      for (final session in sessions) {
        totalPresent += session.presentMemberIds.length;
        totalAbsent += session.absentMemberIds.length;
      }
      final total = totalPresent + totalAbsent;
      if (total > 0) {
        attendanceRate = (totalPresent / total) * 100;
      }
    }

    return Container(
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
        children: [
          // Barre colorée en haut
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  branchColor,
                  branchColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: branchColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            branch.ageRange,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            members.length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const Text(
                            'membres',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (lastSession != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.219,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Color(0xFF4A5565),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Dernière session',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5565),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSessionTypeLabel(lastSession.type),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatDateLong(lastSession.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Taux de présence
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taux de présence',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    Text(
                      '${attendanceRate.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: attendanceRate / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(branchColor),
                  ),
                ),
                const SizedBox(height: 16),
                // Boutons Membres et Présences
                Row(
                  children: [
                    Expanded(
                      child: _buildBranchButton(
                        'Membres',
                        Icons.people,
                        branchColor,
                        () => context.go('/members?branchId=${Uri.encodeComponent(branch.id)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBranchButton(
                        'Présences',
                        Icons.check_circle,
                        branchColor,
                        () => context.go('/attendance?branchId=${Uri.encodeComponent(branch.id)}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(
            color: color.withOpacity(0.19),
            width: 1.219,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
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

  String _getSessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.weekly:
        return 'rencontre dimanche';
      case SessionType.monthly:
        return 'Rencontre mensuelle';
      case SessionType.special:
        return 'Activité spéciale';
    }
  }
}
