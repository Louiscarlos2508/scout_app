import 'package:lainisha/lainisha.dart';
import '../../../domain/entities/user.dart';
import '../../providers/admin_provider.dart';

/// DataProvider personnalisé pour Lainisha utilisant AdminProvider.
class UserLainishaDataProvider extends DataProvider {
  final AdminProvider adminProvider;

  UserLainishaDataProvider(this.adminProvider);

  @override
  Future<List<T>> fetchList<T>(String resource, {int limit = 10, int page = 1}) async {
    // Si les utilisateurs ne sont pas encore chargés, retourner une liste vide
    // Le chargement sera géré par UserManagementScreen ou AdminDashboardScreen
    if (adminProvider.users.isEmpty) {
      // Si le chargement est en cours, attendre qu'il se termine
      if (adminProvider.isLoading) {
        int attempts = 0;
        while (adminProvider.isLoading && attempts < 50) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      } else {
        // Si pas de chargement en cours, retourner liste vide
        // Le widget parent devra déclencher le chargement
        return <T>[];
      }
    }

    // Convertir les User en Map pour Lainisha
    final data = adminProvider.users.map((user) => {
      'id': user.id,
      'nom': user.fullName,
      'email': user.email,
      'rôle': _getRoleLabel(user.role),
      'unité': user.unitId,
    }).toList();

    return data.cast<T>();
  }

  @override
  Future<T> fetchOne<T>(String resource, String id) async {
    final user = adminProvider.users.firstWhere(
      (u) => u.id == id,
      orElse: () => throw Exception('Utilisateur non trouvé'),
    );

    final data = {
      'id': user.id,
      'nom': user.fullName,
      'email': user.email,
      'rôle': _getRoleLabel(user.role),
      'unité': user.unitId,
      'branche': user.branchId ?? 'N/A',
    };
    return data as T;
  }

  @override
  Future<T> create<T>(String resource, Map<String, dynamic> data) async {
    // TODO: Implémenter la création d'utilisateur
    throw UnimplementedError('Création d\'utilisateur non implémentée');
  }

  @override
  Future<T> update<T>(
    String resource,
    String id,
    Map<String, dynamic> data,
  ) async {
    // Convertir le rôle depuis le string
    if (data.containsKey('rôle')) {
      final roleString = data['rôle'] as String;
      final role = _parseRole(roleString);
      final success = await adminProvider.changeUserRole(id, role);
      if (!success) {
        throw Exception('Erreur lors de la mise à jour du rôle');
      }
    }

    // Récupérer l'utilisateur mis à jour
    final updatedUser = adminProvider.users.firstWhere((u) => u.id == id);
    return {
      'id': updatedUser.id,
      'nom': updatedUser.fullName,
      'email': updatedUser.email,
      'rôle': _getRoleLabel(updatedUser.role),
      'unité': updatedUser.unitId,
    } as T;
  }

  @override
  Future<void> delete(String resource, String id) async {
    final success = await adminProvider.removeUser(id);
    if (!success) {
      throw Exception('Erreur lors de la suppression');
    }
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

  UserRole _parseRole(String roleString) {
    switch (roleString) {
      case 'Administrateur':
        return UserRole.admin;
      case 'Chef d\'Unité':
        return UserRole.unitLeader;
      case 'Assistant CU':
        return UserRole.assistantLeader;
      default:
        throw Exception('Rôle invalide: $roleString');
    }
  }
}
