import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/branch_repository_impl.dart';
import '../../data/repositories/stub_member_repository.dart';
import '../../data/repositories/stub_attendance_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/datasources/local/branch_local_datasource.dart';

/// Configuration des repositories de l'application.
class AppRepositories {
  AppRepositories._();

  static final AuthRepository authRepository = AuthRepositoryImpl();
  static final BranchRepository branchRepository = BranchRepositoryImpl(
    localDataSource: BranchLocalDataSourceImpl(),
  );
  static final MemberRepository memberRepository = StubMemberRepository();
  static final AttendanceRepository attendanceRepository =
      StubAttendanceRepository();
}
