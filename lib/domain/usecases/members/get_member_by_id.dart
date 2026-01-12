import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour récupérer un membre par son ID.
class GetMemberById {
  final MemberRepository repository;

  GetMemberById(this.repository);

  Future<Either<Failure, Member>> call(String id) {
    return repository.getMemberById(id);
  }
}
