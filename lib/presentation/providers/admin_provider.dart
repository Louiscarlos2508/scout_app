import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/unit.dart' as entity;
import '../../domain/entities/group.dart';
import '../../core/services/notification_service.dart';
import '../../domain/usecases/admin/get_all_users.dart';
import '../../domain/usecases/admin/update_user_role.dart';
import '../../domain/usecases/admin/delete_user.dart';
import '../../domain/usecases/admin/create_user.dart';
import '../../domain/usecases/admin/get_pending_users.dart';
import '../../domain/usecases/admin/approve_user.dart';
import '../../domain/usecases/units/get_all_units.dart';
import '../../domain/usecases/units/create_unit.dart';
import '../../domain/usecases/units/update_unit.dart';
import '../../domain/usecases/units/delete_unit.dart';
import '../../domain/usecases/groups/get_all_groups.dart';
import '../../domain/usecases/groups/create_group.dart';
import '../../domain/usecases/groups/update_group.dart';
import '../../domain/usecases/groups/delete_group.dart';

/// Provider pour la gestion de l'état de l'administration.
class AdminProvider with ChangeNotifier {
  final GetAllUsers getAllUsers;
  final UpdateUserRole updateUserRole;
  final DeleteUser deleteUser;
  final CreateUser createUser;
  final GetPendingUsers getPendingUsers;
  final ApproveUser approveUser;
  final GetAllUnits getAllUnits;
  final CreateUnit createUnit;
  final UpdateUnit updateUnit;
  final DeleteUnit deleteUnit;
  final GetAllGroups getAllGroups;
  final CreateGroup createGroup;
  final UpdateGroup updateGroup;
  final DeleteGroup deleteGroup;

  AdminProvider({
    required this.getAllUsers,
    required this.updateUserRole,
    required this.deleteUser,
    required this.createUser,
    required this.getPendingUsers,
    required this.approveUser,
    required this.getAllUnits,
    required this.createUnit,
    required this.updateUnit,
    required this.deleteUnit,
    required this.getAllGroups,
    required this.createGroup,
    required this.updateGroup,
    required this.deleteGroup,
  });

  List<User> _users = [];
  List<User> _pendingUsers = [];
  List<entity.Unit> _units = [];
  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<User> get pendingUsers => _pendingUsers;
  List<entity.Unit> get units => _units;
  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge tous les utilisateurs.
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAllUsers();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Met à jour le rôle d'un utilisateur.
  Future<bool> changeUserRole(String userId, UserRole newRole) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateUserRole(userId, newRole);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedUser) {
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Supprime un utilisateur.
  Future<bool> removeUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteUser(userId);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _users.removeWhere((u) => u.id == userId);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Charge les utilisateurs en attente de validation.
  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getPendingUsers();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (users) {
        _pendingUsers = users;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Approuve un utilisateur et définit son rôle, unité et branche.
  Future<bool> approvePendingUser(
    String userId,
    UserRole role, {
    String? unitId,
    String? branchId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await approveUser(
      userId,
      role,
      unitId: unitId,
      branchId: branchId,
    );
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (approvedUser) {
        // Retirer de la liste des en attente
        _pendingUsers.removeWhere((u) => u.id == userId);
        // Ajouter à la liste des utilisateurs approuvés
        _users.add(approvedUser);
        _isLoading = false;
        notifyListeners();
        
        // Envoyer une notification à l'utilisateur
        _sendApprovalNotification(approvedUser, role);
        
        return true;
      },
    );
  }

  /// Met à jour l'unité et la branche d'un utilisateur existant.
  Future<bool> updateUserUnitAndBranch(
    String userId,
    String unitId,
    String branchId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Trouver l'utilisateur dans la liste
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) {
      _error = 'Utilisateur non trouvé';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final currentUser = _users[userIndex];

    // Utiliser approveUser pour mettre à jour l'unité et la branche
    // sans changer le rôle ni le statut
    final result = await approveUser(
      userId,
      currentUser.role, // Garder le rôle actuel
      unitId: unitId,
      branchId: branchId,
    );

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedUser) {
        // Mettre à jour l'utilisateur dans la liste
        _users[userIndex] = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Crée un nouvel utilisateur.
  Future<bool> addUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required UserRole role,
    required String unitId,
    required String branchId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      role: role,
      unitId: unitId,
      branchId: branchId,
    );

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (user) {
        _users.add(user);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  // ========== Gestion des Unités ==========

  /// Charge toutes les unités.
  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAllUnits();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (units) {
        _units = units;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Crée une nouvelle unité.
  Future<bool> addUnit(entity.Unit unit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createUnit(unit);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (createdUnit) {
        _units.add(createdUnit);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Met à jour une unité.
  Future<bool> modifyUnit(entity.Unit unit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateUnit(unit);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedUnit) {
        final index = _units.indexWhere((u) => u.id == unit.id);
        if (index != -1) {
          _units[index] = updatedUnit;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Supprime une unité.
  Future<bool> removeUnit(String unitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteUnit(unitId);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _units.removeWhere((u) => u.id == unitId);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  // ========== Gestion des Groupes ==========

  /// Charge tous les groupes.
  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAllGroups();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (groups) {
        _groups = groups;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Crée un nouveau groupe.
  Future<bool> addGroup(Group group) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createGroup(group);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (createdGroup) {
        _groups.add(createdGroup);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Met à jour un groupe.
  Future<bool> modifyGroup(Group group) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateGroup(group);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedGroup) {
        final index = _groups.indexWhere((g) => g.id == group.id);
        if (index != -1) {
          _groups[index] = updatedGroup;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Envoie une notification à l'utilisateur approuvé.
  void _sendApprovalNotification(User user, UserRole role) {
    // Envoyer la notification de manière asynchrone sans bloquer
    // Ignorer toutes les erreurs pour ne pas perturber le flux d'approbation
    final roleLabel = role == UserRole.unitLeader ? 'Chef d\'unité' : 'Assistant CU';
    
    // Utiliser un Future.microtask pour exécuter de manière complètement asynchrone
    Future.microtask(() async {
      try {
        await NotificationService.sendNotificationToUser(
      userId: user.id,
      title: 'Compte validé ! 🎉',
      body: 'Votre compte a été validé. Vous êtes maintenant $roleLabel. Bienvenue !',
      data: {
        'type': 'user_approved',
        'userId': user.id,
        'role': role.toString().split('.').last,
      },
    );
      } catch (e, stackTrace) {
        // Ignorer complètement les erreurs de notification
        // (peut échouer si l'utilisateur n'a pas de token FCM, sur le web, etc.)
        // Ne pas logger pour éviter le spam dans les logs
      }
    });
  }

  /// Supprime un groupe.
  Future<bool> removeGroup(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteGroup(groupId);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _groups.removeWhere((g) => g.id == groupId);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}
