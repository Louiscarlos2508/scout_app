import 'package:flutter/foundation.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/members/get_members_by_branch.dart';
import '../../domain/usecases/members/create_member.dart';
import '../../domain/usecases/members/update_member.dart';
import '../../domain/usecases/members/delete_member.dart';

/// Provider pour la gestion de l'état des membres.
class MemberProvider with ChangeNotifier {
  final GetMembersByBranch getMembersByBranch;
  final CreateMember createMember;
  final UpdateMember updateMember;
  final DeleteMember deleteMember;

  MemberProvider({
    required this.getMembersByBranch,
    required this.createMember,
    required this.updateMember,
    required this.deleteMember,
  });

  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => _members;
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

  Future<bool> removeMember(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteMember(id);
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
}

