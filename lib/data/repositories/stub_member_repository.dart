import 'package:dartz/dartz.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../../core/errors/failures.dart';

/// Stub temporaire pour MemberRepository (développement UI uniquement).
/// Fournit des données mockées réalistes pour le développement de l'interface.
class StubMemberRepository implements MemberRepository {
  // Données mockées en mémoire
  final List<Member> _mockMembers = [
    // Louveteaux (7-12 ans) - branchId: 'louveteaux'
    Member(
      id: '1',
      firstName: 'Lucas',
      lastName: 'Dubois',
      dateOfBirth: DateTime(2018, 3, 15),
      branchId: 'louveteaux',
      parentPhone: '+33612345678',
      medicalInfo: const MedicalInfo(
        allergies: ['Arachides'],
        bloodGroup: 'A+',
        notes: 'Éviter les produits contenant des arachides',
      ),
    ),
    Member(
      id: '2',
      firstName: 'Emma',
      lastName: 'Martin',
      dateOfBirth: DateTime(2017, 7, 22),
      branchId: 'louveteaux',
      parentPhone: '+33623456789',
      medicalInfo: const MedicalInfo(
        medications: ['Ventoline'],
        bloodGroup: 'O+',
      ),
    ),
    Member(
      id: '3',
      firstName: 'Hugo',
      lastName: 'Bernard',
      dateOfBirth: DateTime(2019, 1, 10),
      branchId: 'louveteaux',
      parentPhone: '+33634567890',
    ),
    // Éclaireurs (13-16 ans) - branchId: 'eclaireurs'
    Member(
      id: '4',
      firstName: 'Léa',
      lastName: 'Petit',
      dateOfBirth: DateTime(2011, 5, 8),
      branchId: 'eclaireurs',
      parentPhone: '+33645678901',
      medicalInfo: const MedicalInfo(
        allergies: ['Lactose'],
        bloodGroup: 'B+',
      ),
    ),
    Member(
      id: '5',
      firstName: 'Thomas',
      lastName: 'Robert',
      dateOfBirth: DateTime(2010, 11, 30),
      branchId: 'eclaireurs',
      parentPhone: '+33656789012',
      medicalInfo: const MedicalInfo(
        illnesses: ['Asthme'],
        medications: ['Ventoline', 'Cortisone'],
        bloodGroup: 'A-',
        notes: 'Avoir toujours la Ventoline à portée de main',
      ),
    ),
    Member(
      id: '6',
      firstName: 'Chloé',
      lastName: 'Richard',
      dateOfBirth: DateTime(2012, 9, 14),
      branchId: 'eclaireurs',
      parentPhone: '+33667890123',
      medicalInfo: const MedicalInfo(
        bloodGroup: 'AB+',
      ),
    ),
    // Sinikié (17-20 ans) - branchId: 'sinikie'
    Member(
      id: '7',
      firstName: 'Nathan',
      lastName: 'Durand',
      dateOfBirth: DateTime(2007, 4, 20),
      branchId: 'sinikie',
      parentPhone: '+33678901234',
      medicalInfo: const MedicalInfo(
        allergies: ['Pénicilline'],
        bloodGroup: 'O-',
        notes: 'Allergie sévère à la pénicilline',
      ),
    ),
    Member(
      id: '8',
      firstName: 'Manon',
      lastName: 'Leroy',
      dateOfBirth: DateTime(2008, 8, 5),
      branchId: 'sinikie',
      parentPhone: '+33689012345',
    ),
    // Routiers (21-25 ans) - branchId: 'routiers'
    Member(
      id: '9',
      firstName: 'Alexandre',
      lastName: 'Moreau',
      dateOfBirth: DateTime(2003, 12, 18),
      branchId: 'routiers',
      parentPhone: '+33690123456',
      medicalInfo: const MedicalInfo(
        bloodGroup: 'A+',
      ),
    ),
    Member(
      id: '10',
      firstName: 'Sophie',
      lastName: 'Simon',
      dateOfBirth: DateTime(2004, 2, 25),
      branchId: 'routiers',
      parentPhone: '+33601234567',
      medicalInfo: const MedicalInfo(
        medications: ['Insuline'],
        bloodGroup: 'B-',
        notes: 'Diabète de type 1 - injections régulières',
      ),
    ),
  ];

  @override
  Future<Either<Failure, List<Member>>> getMembersByBranch(
    String branchId,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    final members = _mockMembers
        .where((member) => member.branchId == branchId)
        .toList();
    
    return Right(members);
  }

  @override
  Future<Either<Failure, Member>> getMemberById(String id) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    final member = _mockMembers.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Member not found'),
    );
    
    return Right(member);
  }

  @override
  Future<Either<Failure, Member>> createMember(Member member) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Générer un nouvel ID
    final newId = (_mockMembers.length + 1).toString();
    final newMember = Member(
      id: newId,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      parentPhone: member.parentPhone,
      medicalInfo: member.medicalInfo,
      lastSync: DateTime.now(),
    );
    
    _mockMembers.add(newMember);
    return Right(newMember);
  }

  @override
  Future<Either<Failure, Member>> updateMember(Member member) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockMembers.indexWhere((m) => m.id == member.id);
    if (index == -1) {
      return Left(ServerFailure('Member not found'));
    }
    
    final updatedMember = Member(
      id: member.id,
      firstName: member.firstName,
      lastName: member.lastName,
      dateOfBirth: member.dateOfBirth,
      branchId: member.branchId,
      parentPhone: member.parentPhone,
      medicalInfo: member.medicalInfo,
      lastSync: DateTime.now(),
    );
    
    _mockMembers[index] = updatedMember;
    return Right(updatedMember);
  }

  @override
  Future<Either<Failure, void>> deleteMember(String id) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockMembers.indexWhere((m) => m.id == id);
    if (index == -1) {
      return Left(ServerFailure('Member not found'));
    }
    
    _mockMembers.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> syncMembers() async {
    // Simuler une synchronisation
    await Future.delayed(const Duration(milliseconds: 1000));
    return const Right(null);
  }
}
