import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour restaurer un membre supprimé.
class RestoreMember {
  final MemberRepository repository;

  RestoreMember(this.repository);

  Future<Either<Failure, Member>> call(String id) {
    return repository.restoreMember(id);
  }
}
