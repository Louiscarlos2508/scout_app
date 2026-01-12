import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/admin_provider.dart';
import '../../presentation/providers/member_provider.dart';
import '../../presentation/providers/attendance_provider.dart';
import '../../presentation/providers/branch_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/branch_repository_impl.dart';
import '../../data/datasources/local/branch_local_datasource.dart';
import '../../data/repositories/member_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/datasources/local/member_local_datasource.dart';
import '../../data/datasources/local/attendance_local_datasource.dart';
import '../../data/datasources/remote/member_remote_datasource.dart';
import '../../data/datasources/remote/attendance_remote_datasource.dart';
import '../../core/network/network_info.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/signup.dart';
import '../../domain/usecases/auth/sign_in_with_google.dart';
import '../../domain/usecases/auth/complete_google_user_info.dart';
import '../../domain/usecases/admin/get_all_users.dart';
import '../../domain/usecases/admin/update_user_role.dart';
import '../../domain/usecases/admin/delete_user.dart';
import '../../domain/usecases/admin/create_user.dart';
import '../../domain/usecases/admin/get_pending_users.dart';
import '../../domain/usecases/admin/approve_user.dart';
import '../../domain/usecases/units/get_all_units.dart';
import '../../domain/usecases/units/create_unit.dart';
import '../../domain/usecases/units/update_unit.dart';
import '../../domain/usecases/units/delete_unit.dart';
import '../../domain/usecases/groups/get_all_groups.dart';
import '../../domain/usecases/groups/create_group.dart';
import '../../domain/usecases/groups/update_group.dart';
import '../../domain/usecases/groups/delete_group.dart';
import '../../data/repositories/unit_repository_impl.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../data/datasources/remote/unit_remote_datasource.dart';
import '../../data/datasources/remote/group_remote_datasource.dart';
import '../../domain/usecases/members/get_members_by_branch.dart';
import '../../domain/usecases/members/get_member_by_id.dart';
import '../../domain/usecases/members/create_member.dart';
import '../../domain/usecases/members/update_member.dart';
import '../../domain/usecases/members/delete_member.dart';
import '../../domain/usecases/members/restore_member.dart';
import '../../domain/usecases/members/get_deleted_members.dart';
import '../../domain/usecases/attendance/get_attendance_sessions.dart';
import '../../domain/usecases/attendance/create_attendance_session.dart';
import '../../domain/usecases/attendance/mark_attendance.dart';
import '../../domain/usecases/attendance/sync_attendance.dart';

/// Configuration des providers de l'application.
class AppProviders {
  AppProviders._();

  /// Liste de tous les providers de l'application.
  static final providers = [
    /// 🔐 AUTH
    ChangeNotifierProvider<AuthProvider>(
      create: (_) {
        final authRepository = AuthRepositoryImpl();
        return AuthProvider(
          login: Login(authRepository),
          logout: Logout(authRepository),
          getCurrentUser: GetCurrentUser(authRepository),
          signUpUseCase: SignUp(authRepository),
          signInWithGoogleUseCase: SignInWithGoogle(authRepository),
          completeGoogleUserInfoUseCase: CompleteGoogleUserInfo(authRepository),
        );
      },
    ),

    /// 👮 ADMIN
    ChangeNotifierProvider<AdminProvider>(
      create: (_) {
        final authRepository = AuthRepositoryImpl();
        final unitRemoteDataSource = UnitRemoteDataSourceImpl();
        final unitRepository = UnitRepositoryImpl(
          remoteDataSource: unitRemoteDataSource,
        );
        final groupRemoteDataSource = GroupRemoteDataSourceImpl();
        final groupRepository = GroupRepositoryImpl(
          remoteDataSource: groupRemoteDataSource,
        );
        return AdminProvider(
          getAllUsers: GetAllUsers(authRepository),
          updateUserRole: UpdateUserRole(authRepository),
          deleteUser: DeleteUser(authRepository),
          createUser: CreateUser(authRepository),
          getPendingUsers: GetPendingUsers(authRepository),
          approveUser: ApproveUser(authRepository),
          getAllUnits: GetAllUnits(unitRepository),
          createUnit: CreateUnit(unitRepository),
          updateUnit: UpdateUnit(unitRepository),
          deleteUnit: DeleteUnit(unitRepository),
          getAllGroups: GetAllGroups(groupRepository),
          createGroup: CreateGroup(groupRepository),
          updateGroup: UpdateGroup(groupRepository),
          deleteGroup: DeleteGroup(groupRepository),
        );
      },
    ),

    /// 👥 MEMBERS
    ChangeNotifierProvider<MemberProvider>(
      create: (_) {
        final localDataSource = MemberLocalDataSourceImpl();
        final remoteDataSource = MemberRemoteDataSourceImpl();
        final networkInfo = NetworkInfoImpl();
        final repo = MemberRepositoryImpl(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
          networkInfo: networkInfo,
        );
        return MemberProvider(
          getMembersByBranch: GetMembersByBranch(repo),
          getMemberById: GetMemberById(repo),
          createMember: CreateMember(repo),
          updateMember: UpdateMember(repo),
          deleteMember: DeleteMember(repo),
          restoreMember: RestoreMember(repo),
          getDeletedMembers: GetDeletedMembers(repo),
        );
      },
    ),

    /// 📋 ATTENDANCE
    ChangeNotifierProvider<AttendanceProvider>(
      create: (_) {
        final localDataSource = AttendanceLocalDataSourceImpl();
        final remoteDataSource = AttendanceRemoteDataSourceImpl();
        final networkInfo = NetworkInfoImpl();
        final repo = AttendanceRepositoryImpl(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
          networkInfo: networkInfo,
        );
        return AttendanceProvider(
          getAttendanceSessions: GetAttendanceSessions(repo),
          createAttendanceSession: CreateAttendanceSession(repo),
          markAttendance: MarkAttendance(repo),
          syncAttendance: SyncAttendance(repo),
        );
      },
    ),

    /// 🌍 BRANCH
    ChangeNotifierProvider<BranchProvider>(
      create: (_) {
        final localDataSource = BranchLocalDataSourceImpl();
        final repository = BranchRepositoryImpl(
          localDataSource: localDataSource,
        );
        return BranchProvider(repository: repository);
      },
    ),
  ];
}
