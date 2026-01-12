import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour récupérer tous les membres supprimés.
class GetDeletedMembers {
  final MemberRepository repository;

  GetDeletedMembers(this.repository);

  Future<Either<Failure, List<Member>>> call() {
    return repository.getDeletedMembers();
  }
}
