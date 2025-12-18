import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/member.dart';
import '../../repositories/member_repository.dart';

/// Use case pour mettre à jour un membre.
class UpdateMember {
  final MemberRepository repository;

  UpdateMember(this.repository);

  Future<Either<Failure, Member>> call(Member member) {
    return repository.updateMember(member);
  }
}

