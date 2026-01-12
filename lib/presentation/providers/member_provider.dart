import 'package:flutter/foundation.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/members/get_members_by_branch.dart';
import '../../domain/usecases/members/get_member_by_id.dart';
import '../../domain/usecases/members/create_member.dart';
import '../../domain/usecases/members/update_member.dart';
import '../../domain/usecases/members/delete_member.dart';
import '../../domain/usecases/members/restore_member.dart';
import '../../domain/usecases/members/get_deleted_members.dart';

/// Provider pour la gestion de l'état des membres.
class MemberProvider with ChangeNotifier {
  final GetMembersByBranch getMembersByBranch;
  final GetMemberById getMemberById;
  final CreateMember createMember;
  final UpdateMember updateMember;
  final DeleteMember deleteMember;
  final RestoreMember restoreMember;
  final GetDeletedMembers getDeletedMembers;

  MemberProvider({
    required this.getMembersByBranch,
    required this.getMemberById,
    required this.createMember,
    required this.updateMember,
    required this.deleteMember,
    required this.restoreMember,
    required this.getDeletedMembers,
  });

  List<Member> _members = [];
  List<Member> _deletedMembers = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => _members;
  List<Member> get deletedMembers => _deletedMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMembersByBranch(String branchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMembersByBranch(branchId);
    result.fold(
      (failure) => _error = failure.message,
      (members) => _members = members,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Charge un membre par son ID.
  Future<Member?> loadMemberById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMemberById(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (member) {
        // Ajouter ou mettre à jour le membre dans la liste
        final index = _members.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          _members[index] = member;
        } else {
          _members.add(member);
        }
        _isLoading = false;
        notifyListeners();
        return member;
      },
    );
  }

  Future<bool> addMember(Member member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createMember(member);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (createdMember) {
        _members.add(createdMember);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> modifyMember(Member member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateMember(member);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedMember) {
        final index = _members.indexWhere((m) => m.id == updatedMember.id);
        if (index != -1) {
          _members[index] = updatedMember;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeMember(String id, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteMember(id, reason);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _members.removeWhere((m) => m.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> loadDeletedMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getDeletedMembers();
    result.fold(
      (failure) {
        _error = failure.message;
        _deletedMembers = [];
      },
      (members) {
        _deletedMembers = members;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> restoreDeletedMember(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await restoreMember(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (restoredMember) {
        _deletedMembers.removeWhere((m) => m.id == id);
        _members.add(restoredMember);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}

