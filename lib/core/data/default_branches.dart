import '../../domain/entities/branch.dart';
import '../constants/app_constants.dart';

/// Données par défaut des branches codées en dur.
/// 
/// Les branches ne sont pas stockées dans Firestore mais sont définies
/// directement dans le code de l'application.
class DefaultBranches {
  DefaultBranches._();

  /// Liste de toutes les branches par défaut.
  static List<Branch> get allBranches => [
        const Branch(
          id: 'louveteaux',
          name: AppConstants.branchLouveteaux,
          color: AppConstants.branchLouveteauxColor,
          minAge: AppConstants.louveteauxMinAge,
          maxAge: AppConstants.louveteauxMaxAge,
        ),
        const Branch(
          id: 'eclaireurs',
          name: AppConstants.branchEclaireurs,
          color: AppConstants.branchEclaireursColor,
          minAge: AppConstants.eclaireursMinAge,
          maxAge: AppConstants.eclaireursMaxAge,
        ),
        const Branch(
          id: 'sinikie',
          name: AppConstants.branchSinikie,
          color: AppConstants.branchSinikieColor,
          minAge: AppConstants.sinikieMinAge,
          maxAge: AppConstants.sinikieMaxAge,
        ),
        const Branch(
          id: 'routiers',
          name: AppConstants.branchRoutiers,
          color: AppConstants.branchRoutiersColor,
          minAge: AppConstants.routiersMinAge,
          maxAge: AppConstants.routiersMaxAge,
        ),
      ];

  /// Récupère une branche par son ID.
  static Branch? getBranchById(String id) {
    try {
      return allBranches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Normalise un ID de branche depuis Firestore vers l'ID standard.
  /// 
  /// Convertit des formats comme "branch-louveteaux-1" vers "louveteaux".
  /// Si l'ID est déjà dans le format standard, il est retourné tel quel.
  /// 
  /// Exemples:
  /// - "branch-louveteaux-1" → "louveteaux"
  /// - "louveteaux" → "louveteaux"
  /// - "branch-eclaireurs-2" → "eclaireurs"
  static String normalizeBranchId(String branchId) {
    // Si c'est déjà un ID valide, le retourner tel quel
    if (getBranchById(branchId) != null) {
      return branchId;
    }

    // Extraire le nom de la branche depuis des formats comme "branch-louveteaux-1"
    // Patterns possibles:
    // - "branch-{name}-{number}" → "{name}"
    // - "branch-{name}" → "{name}"
    final regex = RegExp(r'^branch-([a-z]+)(?:-\d+)?$', caseSensitive: false);
    final match = regex.firstMatch(branchId);
    
    if (match != null && match.groupCount >= 1) {
      final normalizedId = match.group(1)?.toLowerCase() ?? branchId;
      // Vérifier que l'ID normalisé existe
      if (getBranchById(normalizedId) != null) {
        return normalizedId;
      }
    }

    // Si on ne peut pas normaliser, retourner l'ID original
    // (peut-être que c'est un format différent qu'on ne connaît pas)
    return branchId;
  }

  /// Récupère une branche par son ID, en normalisant l'ID d'abord.
  /// 
  /// Utile pour récupérer une branche à partir d'un ID Firestore
  /// qui pourrait être dans un format différent.
  static Branch? getBranchByNormalizedId(String branchId) {
    final normalizedId = normalizeBranchId(branchId);
    return getBranchById(normalizedId);
  }
}

