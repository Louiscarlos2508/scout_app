import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/member.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/user.dart';
import '../../../core/data/default_branches.dart';

/// Écran affichant la liste des membres d'une branche.
/// 
/// Design basé sur Figma: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=74-315
class MembersListScreen extends StatefulWidget {
  final String? branchId;

  const MembersListScreen({
    super.key,
    this.branchId,
  });

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  String? _selectedBranchId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId;
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMembers() {
    if (_selectedBranchId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MemberProvider>(context, listen: false)
            .loadMembersByBranch(_selectedBranchId!);
      });
    }
  }

  List<Member> _filterMembers(List<Member> members) {
    if (_searchQuery.isEmpty) {
      return members;
    }
    final query = _searchQuery.toLowerCase();
    return members.where((member) {
      return member.fullName.toLowerCase().contains(query) ||
          member.firstName.toLowerCase().contains(query) ||
          member.lastName.toLowerCase().contains(query);
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Consumer4<MemberProvider, BranchProvider, AuthProvider, AdminProvider>(
      builder: (context, memberProvider, branchProvider, authProvider, adminProvider, child) {
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
          // Branche non trouvée
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
                    onPressed: () => context.go('/'),
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

        // À ce point, branch n'est plus null
        final nonNullBranch = branch;
        final branchColor = _getBranchColor(nonNullBranch.id);
        final filteredMembers = _filterMembers(memberProvider.members);

        // Pas besoin de PopScope : le retour normal fonctionne automatiquement avec go_router
        return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Stack(
              children: [
              // Structure principale inspirée de profil : Column avec header et liste
              Column(
                children: [
                  // Header avec gradient de la couleur de la branche
                  _buildHeader(nonNullBranch, branchColor, user, adminProvider),
                  // Liste des membres (prend toute la hauteur restante)
                  // Le padding est géré dans _buildMembersList pour éviter que les cartes soient cachées
                  Expanded(
                    child: _buildMembersList(
                      memberProvider,
                      filteredMembers,
                      branchColor,
                    ),
                  ),
                ],
              ),
              // Section de recherche et action (positionnée pour chevaucher le header)
              // Position ajustée pour avoir un espacement après la carte du nombre de membres
              Positioned(
                top: 360, // Position ajustée pour avoir un espacement après la carte du nombre de membres
                left: 24,
                right: 24,
                child: _buildSearchAndAction(branchColor),
              ),
              ],
            ),
        );
      },
    );
  }

  /// Header avec gradient de la couleur de la branche
  /// Inspiré de la structure du profil pour prendre toute la place
  Widget _buildHeader(Branch branch, Color branchColor, User user, AdminProvider adminProvider) {
    final gradientColors = [
      branchColor,
      branchColor.withOpacity(0.933),
      branchColor.withOpacity(0.867),
    ];

    // Angle du gradient selon Figma: 139.07141949322704deg
    // Convertir en radians pour Flutter: 139.07141949322704 * pi / 180
    const double angleDeg = 139.07141949322704;
    final double angleRad = angleDeg * math.pi / 180;
    final double cosAngle = math.cos(angleRad);
    final double sinAngle = math.sin(angleRad);

    return Container(
      height: 380.526,
      width: double.infinity, // Prend toute la largeur comme dans profil
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-cosAngle, -sinAngle),
          end: Alignment(cosAngle, sinAngle),
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Effet de blur décoratif (cercle blanc avec blur en haut à droite)
          Positioned(
            right: 86.85,
            top: -128,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Contenu du header inspiré de profil
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour (aligné à gauche comme dans profil)
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
                  // Nom de la branche
                  Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nom de l'unité
                  Text(
                    _getUnitDisplayName(user.unitId, adminProvider),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Badge avec plage d'âge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      branch.ageRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Espacement entre le badge d'âge et la carte du nombre de membres
                  // Carte avec nombre de membres
                  Consumer<MemberProvider>(
            builder: (context, provider, child) {
                      final totalMembers = provider.members.length;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17.219),
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
                            Text(
                              totalMembers.toString(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Membres actifs',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(), // Utiliser Spacer pour occuper l'espace restant
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section de recherche et action
  Widget _buildSearchAndAction(Color branchColor) {
    return Container(
      padding: const EdgeInsets.all(16), // Padding équilibré de tous les côtés
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ de recherche
          Container(
            height: 46.437,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 1.219,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF101828).withOpacity(0.5),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xFF6A7282),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bouton "Ajouter un membre"
          InkWell(
            onTap: () => context.go(
              '/members/new?branchId=${Uri.encodeComponent(_selectedBranchId ?? '')}',
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 47.999,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF45556C), Color(0xFF314158)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
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
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Ajouter un membre',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Liste des membres
  Widget _buildMembersList(
    MemberProvider provider,
    List<Member> members,
    Color branchColor,
  ) {
              if (provider.isLoading && provider.members.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            const Icon(
                        Icons.error_outline,
                        size: 64,
              color: Color(0xFFDC2626),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur: ${provider.error}',
              style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMembers,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

    if (members.isEmpty) {
      return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
              _searchQuery.isEmpty
                  ? 'Aucun membre dans cette branche'
                  : 'Aucun membre trouvé',
              style: TextStyle(
                fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
      );
    }

    // Ajouter un padding en haut pour que la liste commence après la carte de recherche/action
    // La carte de recherche/action est positionnée à 340px du haut
    // Hauteur de la carte : 16 (padding top) + 46.437 (recherche) + 16 (espace) + 47.999 (bouton) + 16 (padding bottom) = 142.436px
    // Donc elle se termine à environ 340 + 142.436 = 482.436px
    // Le header se termine à 380.526px
    // Calcul: (482.436 - 380.526) + 16 (espace supplémentaire) = 101.91 + 16 ≈ 118px
    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 130, // Espace pour que la liste commence après la carte de recherche/action (avec marge de sécurité)
        left: 24,
        right: 24,
        bottom: 12,
      ),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member, branchColor);
      },
    );
  }

  /// Carte d'un membre
  Widget _buildMemberCard(Member member, Color branchColor) {
    final initials = '${member.firstName[0].toUpperCase()}${member.lastName.isNotEmpty ? member.lastName[0].toUpperCase() : ''}';
    
    // Déterminer le badge d'avertissement
    String? warningText;
    Color? warningColor;
    Color? warningBorderColor;
    
    if (member.medicalInfo != null) {
      if (member.medicalInfo!.allergies.isNotEmpty) {
        warningText = '⚠️ Allergies';
        warningColor = const Color(0xFFFEF2F2);
        warningBorderColor = const Color(0xFFFFE2E2);
      } else if (member.medicalInfo!.illnesses.isNotEmpty ||
          member.medicalInfo!.medications.isNotEmpty) {
        warningText = '💊 Médical';
        warningColor = const Color(0xFFFFF7ED);
        warningBorderColor = const Color(0xFFFFEDD4);
      }
    }

    final gradientColors = [
      branchColor,
      branchColor.withOpacity(0.867),
    ];

    return InkWell(
      onTap: () => context.go('/members/${member.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              blurRadius: 4,
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
          children: [
            // Avatar avec initiales
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
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
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Nom et âge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.age} ans',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ),
            ),
            // Badge d'avertissement
            if (warningText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: warningColor,
                  border: Border.all(
                    color: warningBorderColor!,
                    width: 1.219,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  warningText,
                  style: TextStyle(
                    fontSize: 12,
                    color: warningText.contains('Allergies')
                        ? const Color(0xFFE7000B)
                        : const Color(0xFFF54900),
                  ),
          ),
        ),
      ],
        ),
      ),
    );
  }
}
