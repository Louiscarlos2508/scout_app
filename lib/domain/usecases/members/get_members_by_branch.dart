import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour récupérer les membres d'une branche.
class GetMembersByBranch {
  final MemberRepository repository;

  GetMembersByBranch(this.repository);

  Future<Either<Failure, List<Member>>> call(String branchId) {
    return repository.getMembersByBranch(branchId);
  }
}

