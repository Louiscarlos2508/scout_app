import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour créer un nouveau membre.
class CreateMember {
  final MemberRepository repository;

  CreateMember(this.repository);

  Future<Either<Failure, Member>> call(Member member) {
    return repository.createMember(member);
  }
}

