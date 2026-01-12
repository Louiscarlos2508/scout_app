import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/waiting_approval_screen.dart';
import '../screens/auth/complete_google_info_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/unit_form_screen.dart';
import '../screens/admin/group_form_screen.dart';
import '../screens/admin/user_form_screen.dart';
import '../screens/admin/groups_overview_screen.dart' show UnitsOverviewScreen;
import '../screens/admin/pending_users_screen.dart';
import '../screens/admin/deleted_members_screen.dart';
import '../screens/members/members_list_screen.dart';
import '../screens/members/member_detail_screen.dart';
import '../screens/members/member_form_screen.dart';
import '../screens/attendance/attendance_list_screen.dart';
import '../screens/attendance/create_session_screen.dart';
import '../screens/attendance/attendance_session_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/layout/main_layout.dart';

/// Configuration du routeur de l'application avec go_router.
class AppRouter {
  /// Crée le router avec accès aux providers.
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = authProvider.isAuthenticated;
        final currentUser = authProvider.currentUser;
        final currentPath = state.uri.path;
        final loggingIn = currentPath == '/login';
        final isSignup = currentPath == '/signup';
        final isWaiting = currentPath == '/waiting-approval';
        final isCompleteGoogleInfo = currentPath == '/complete-google-info';
        final isSplash = currentPath == '/';
        final isAdminRoute = currentPath.startsWith('/admin');
        
        // Routes publiques qui ne nécessitent pas d'authentification
        final publicRoutes = ['/login', '/signup'];
        // Routes authentifiées valides (ne pas rediriger depuis ces routes)
        final validAuthenticatedRoutes = [
          '/home', '/profile', '/members', '/attendance',
          '/admin', '/admin/users', '/admin/pending-users', 
          '/admin/units/overview', '/waiting-approval'
        ];
        final isMemberRoute = currentPath.startsWith('/members');
        final isAttendanceRoute = currentPath.startsWith('/attendance');
        final isValidAuthenticatedRoute = validAuthenticatedRoutes.contains(currentPath) ||
            isMemberRoute || isAttendanceRoute || isAdminRoute;

        // Si on est sur le splash, rediriger selon l'état d'auth
        if (isSplash) {
          if (loggedIn) {
            // Les admins ont toujours accès, même s'ils sont en pending
            if (currentUser?.hasAdminAccess ?? false) {
              return '/admin';
            }
            // Si l'utilisateur est en attente (et n'est pas admin), rediriger vers l'écran d'attente
            if (currentUser?.isPending ?? false) {
              return '/waiting-approval';
            }
            // Rediriger les autres vers /home
            return '/home';
          } else {
            return '/login';
          }
        }

        // Si on n'est pas authentifié et qu'on n'est pas sur une route publique, rediriger vers login
        if (!loggedIn && !publicRoutes.contains(currentPath) && !isCompleteGoogleInfo) {
          return '/login';
        }

        // Si on est authentifié et sur une route publique (login/signup), rediriger
        if (loggedIn && (loggingIn || isSignup)) {
          // Les admins ont toujours accès
          if (currentUser?.hasAdminAccess ?? false) {
            return '/admin';
          }
          // Les autres utilisateurs en attente vont vers waiting-approval
          if (currentUser?.isPending == true) {
            return '/waiting-approval';
          }
          return '/home';
        }

        // Si on est authentifié mais que les infos Google sont incomplètes, rediriger vers complete-google-info
        // IMPORTANT: Les admins ne doivent pas être redirigés vers cette page car ils sont créés directement par un admin
        if (loggedIn && currentUser != null && !(currentUser!.hasAdminAccess)) {
          final needsInfo = currentUser!.phoneNumber.isEmpty ||
              currentUser!.unitId.isEmpty ||
              currentUser!.branchId.isEmpty;
          if (needsInfo && !isCompleteGoogleInfo && !isWaiting && isValidAuthenticatedRoute) {
            return '/complete-google-info';
          }
        }

        // Si on est authentifié et en attente (sauf admin), rediriger vers l'écran d'attente
        // MAIS seulement si on n'est pas déjà sur une route valide
        if (loggedIn && 
            currentUser?.isPending == true && 
            !(currentUser?.hasAdminAccess ?? false) &&
            !isWaiting &&
            !isCompleteGoogleInfo &&
            isValidAuthenticatedRoute) {
          return '/waiting-approval';
        }

        // Vérifier l'accès admin pour les routes admin
        if (isAdminRoute && loggedIn) {
          if (currentUser == null || !currentUser.hasAdminAccess) {
            // Rediriger vers home si pas les droits admin
            return '/home';
          }
        }

        // Si on est authentifié et sur une route valide, ne pas rediriger
        // Cela évite les redirections lors des hot reloads
        if (loggedIn && isValidAuthenticatedRoute) {
          return null; // Rester sur la route actuelle
        }

        return null; // Pas de redirection nécessaire
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/waiting-approval',
          name: 'waiting-approval',
          builder: (context, state) => const WaitingApprovalScreen(),
        ),
        GoRoute(
          path: '/complete-google-info',
          name: 'complete-google-info',
          builder: (context, state) => const CompleteGoogleInfoScreen(),
        ),
        // Route home (a son propre Scaffold avec header personnalisé)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        // Route profile (a son propre Scaffold)
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // Shell Route pour les pages authentifiées avec layout persistant
        ShellRoute(
          builder: (context, state, child) {
            // Vérifier si c'est une route admin (qui a son propre layout)
            final isAdminRoute = state.uri.path.startsWith('/admin');
            if (isAdminRoute) {
              // Les routes admin utilisent leur propre layout (LainishaAdmin)
              return child;
            }
            
            // Vérifier si c'est une route qui a son propre Scaffold (ne pas utiliser MainLayout)
            final path = state.uri.path;
            // Routes avec leur propre Scaffold : liste des membres, détails, formulaires, sessions
            final hasOwnScaffold = path == '/members' || // /members (liste avec header personnalisé selon Figma)
                                   path == '/attendance' || // /attendance (liste avec header personnalisé selon Figma)
                                   RegExp(r'^/members/[^/]+$').hasMatch(path) || // /members/:id
                                   RegExp(r'^/members/[^/]+/edit$').hasMatch(path) || // /members/:id/edit
                                   path == '/members/new' || // /members/new
                                   RegExp(r'^/attendance/[^/]+$').hasMatch(path) || // /attendance/:id
                                   path == '/attendance/new'; // /attendance/new
            
            if (hasOwnScaffold) {
              // Les routes avec leur propre Scaffold sont affichées sans MainLayout
              return child;
            }
            
            // Les autres routes utilisent le MainLayout avec drawer
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/members',
              name: 'members',
              builder: (context, state) {
                final branchId = state.uri.queryParameters['branchId'];
                return MembersListScreen(branchId: branchId);
              },
            ),
            GoRoute(
              path: '/members/new',
              name: 'member-new',
              builder: (context, state) {
                final branchId = state.uri.queryParameters['branchId'];
                return MemberFormScreen(branchId: branchId);
              },
            ),
            GoRoute(
              path: '/members/:id',
              name: 'member-detail',
              builder: (context, state) {
                final memberId = state.pathParameters['id']!;
                return MemberDetailScreen(memberId: memberId);
              },
            ),
            GoRoute(
              path: '/members/:id/edit',
              name: 'member-edit',
              builder: (context, state) {
                final memberId = state.pathParameters['id']!;
                return MemberFormScreen(memberId: memberId);
              },
            ),
            GoRoute(
              path: '/attendance',
              name: 'attendance',
              builder: (context, state) {
                final branchId = state.uri.queryParameters['branchId'];
                return AttendanceListScreen(branchId: branchId);
              },
            ),
            GoRoute(
              path: '/attendance/new',
              name: 'attendance-new',
              builder: (context, state) {
                final branchId = state.uri.queryParameters['branchId'];
                return CreateSessionScreen(branchId: branchId);
              },
            ),
            GoRoute(
              path: '/attendance/:id',
              name: 'attendance-session',
              builder: (context, state) {
                final sessionId = state.pathParameters['id']!;
                return AttendanceSessionScreen(sessionId: sessionId);
              },
            ),
          ],
        ),
        // Routes admin (sans layout persistant car LainishaAdmin a son propre Scaffold)
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/admin/users/new',
          name: 'admin-users-new',
          builder: (context, state) {
            final unitId = state.uri.queryParameters['unitId'];
            return UserFormScreen();
          },
        ),
        GoRoute(
          path: '/admin/units/new',
          name: 'admin-units-new',
          builder: (context, state) => const UnitFormScreen(),
        ),
        GoRoute(
          path: '/admin/units/:id/edit',
          name: 'admin-units-edit',
          builder: (context, state) {
            final unitId = state.pathParameters['id']!;
            return UnitFormScreen(unitId: unitId);
          },
        ),
        GoRoute(
          path: '/admin/pending-users',
          name: 'admin-pending-users',
          builder: (context, state) => const PendingUsersScreen(),
        ),
        GoRoute(
          path: '/admin/units/overview',
          name: 'admin-units-overview',
          builder: (context, state) => const UnitsOverviewScreen(),
        ),
        GoRoute(
          path: '/admin/deleted-members',
          name: 'admin-deleted-members',
          builder: (context, state) => const DeletedMembersScreen(),
        ),
      ],
    );
  }
}
