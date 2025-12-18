import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/member_repository.dart';

/// Use case pour supprimer un membre.
class DeleteMember {
  final MemberRepository repository;

  DeleteMember(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteMember(id);
  }
}

