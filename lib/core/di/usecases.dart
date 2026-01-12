import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/admin/get_all_users.dart';
import '../../domain/usecases/admin/update_user_role.dart';
import '../../domain/usecases/admin/delete_user.dart';
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
import 'repositories.dart';

/// Configuration des use cases de l'application.
class AppUseCases {
  AppUseCases._();

  // Auth use cases
  static final Login login = Login(AppRepositories.authRepository);
  static final Logout logout = Logout(AppRepositories.authRepository);
  static final GetCurrentUser getCurrentUser =
      GetCurrentUser(AppRepositories.authRepository);

  // Admin use cases
  static final GetAllUsers getAllUsers =
      GetAllUsers(AppRepositories.authRepository);
  static final UpdateUserRole updateUserRole =
      UpdateUserRole(AppRepositories.authRepository);
  static final DeleteUser deleteUser =
      DeleteUser(AppRepositories.authRepository);

  // Member use cases
  static final GetMembersByBranch getMembersByBranch =
      GetMembersByBranch(AppRepositories.memberRepository);
  static final GetMemberById getMemberById =
      GetMemberById(AppRepositories.memberRepository);
  static final CreateMember createMember =
      CreateMember(AppRepositories.memberRepository);
  static final UpdateMember updateMember =
      UpdateMember(AppRepositories.memberRepository);
  static final DeleteMember deleteMember =
      DeleteMember(AppRepositories.memberRepository);
  static final RestoreMember restoreMember =
      RestoreMember(AppRepositories.memberRepository);
  static final GetDeletedMembers getDeletedMembers =
      GetDeletedMembers(AppRepositories.memberRepository);

  // Attendance use cases
  static final GetAttendanceSessions getAttendanceSessions =
      GetAttendanceSessions(AppRepositories.attendanceRepository);
  static final CreateAttendanceSession createAttendanceSession =
      CreateAttendanceSession(AppRepositories.attendanceRepository);
  static final MarkAttendance markAttendance =
      MarkAttendance(AppRepositories.attendanceRepository);
  static final SyncAttendance syncAttendance =
      SyncAttendance(AppRepositories.attendanceRepository);
}
