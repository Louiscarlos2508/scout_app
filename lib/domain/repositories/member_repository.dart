import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/member.dart';

/// Interface du repository pour la gestion des membres.
abstract class MemberRepository {
  /// Récupère tous les membres d'une branche.
  Future<Either<Failure, List<Member>>> getMembersByBranch(String branchId);

  /// Récupère un membre par son ID.
  Future<Either<Failure, Member>> getMemberById(String id);

  /// Crée un nouveau membre.
  Future<Either<Failure, Member>> createMember(Member member);

  /// Met à jour un membre existant.
  Future<Either<Failure, Member>> updateMember(Member member);

  /// Supprime un membre.
  Future<Either<Failure, void>> deleteMember(String id);

  /// Synchronise les membres avec le serveur.
  Future<Either<Failure, void>> syncMembers();
}

