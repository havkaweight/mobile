import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/data/api/token_storage.dart';
import 'package:havka/presentation/screens/developer_screen.dart';
import 'package:havka/presentation/screens/fridge_adjustment_screen.dart';
import 'package:havka/presentation/screens/profile_edit_screen.dart';
import 'package:havka/presentation/screens/scale_screen.dart';
import 'package:havka/presentation/screens/story_screen.dart';
import 'package:havka/presentation/screens/termination_screen.dart';
import 'package:havka/routes/sharp_page_route.dart';
import 'package:provider/provider.dart';
import '../domain/entities/fridge/user_fridge.dart';
import '../domain/entities/product/fridge_item.dart';
import '../domain/entities/profile/profile.dart';
import '../domain/entities/user/user.dart';
import '../presentation/screens/chat_screen.dart';
import '../presentation/screens/chats_list_screen.dart';
import '../presentation/screens/daily_intake_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/stats_screen.dart';
import '../presentation/screens/username_change_screen.dart';
import '/presentation/screens/profile_screen.dart';
import '/presentation/screens/auth_screen.dart';
import '/presentation/screens/fridge_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _statsNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _fridgeNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/fridge',
      refreshListenable: _AppRouterRefreshStream(),
      redirect: (context, state) async {
        final accessToken = await TokenStorage().getAccessToken();
        final publicPaths = {'/login', '/about'};

        if (publicPaths.contains(state.uri.path)) {
          return null;
        }

        if (accessToken == null) {
          return '/login';
        }

        return null;
      },
      routes: [
        // GoRoute(
        //   path: '/',
        //   builder: (context, state) => AuthScreen(),
        // ),
        GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/login',
            pageBuilder: (context, state) => CustomTransitionPage(
                  transitionsBuilder:
                      (context, animation, secondAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: AuthScreen(),
                )),
        GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/about',
            pageBuilder: (context, state) => CustomTransitionPage(
                  transitionsBuilder:
                      (context, animation, secondAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: StoryPage(),
                )),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainScreen(navigationShell),
          branches: [
            StatefulShellBranch(navigatorKey: _statsNavigatorKey, routes: [
              GoRoute(
                  path: '/stats', builder: (context, state) => StatsScreen()),
            ]),
            StatefulShellBranch(navigatorKey: _fridgeNavigatorKey, routes: [
              GoRoute(
                  path: '/fridge',
                  builder: (context, state) {
                    return FridgeScreen();
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'add',
                      builder: (context, state) => FridgeAdjustmentScreen(),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'edit',
                      builder: (context, state) => FridgeAdjustmentScreen(
                          userFridge: state.extra as UserFridge?),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'items/:item_id',
                      builder: (context, state) {
                        final fridgeItemId = state.pathParameters['item_id'];
                        return ScaleScreen(
                            fridgeItem: state.extra as FridgeItem);
                      },
                    ),
                  ]),
            ]),
            StatefulShellBranch(navigatorKey: _profileNavigatorKey, routes: [
              GoRoute(
                  path: '/profile',
                  builder: (context, state) => ProfileScreen(),
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "chats",
                      builder: (_, state) => ChatsListScreen(),
                      routes: [
                        GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: "chat",
                          builder: (_, state) =>
                              ChatScreen(user: state.extra as String?),
                        ),
                      ],
                    ),
                    GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        path: 'edit',
                        builder: (context, state) {
                          final extra = state.extra as Map<String, dynamic>;
                          return ProfileEditingScreen(
                            user: extra['user'] as User,
                            profile: extra['profile'] as Profile,
                          );
                        },
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigatorKey,
                            path: 'username',
                            builder: (context, state) {
                              final user = state.extra as User;
                              return UsernameChangeScreen(user: user);
                            },
                          ),
                          GoRoute(
                            parentNavigatorKey: _rootNavigatorKey,
                            path: 'logout',
                            builder: (context, state) {
                              final user = state.extra as User;
                              return UsernameChangeScreen(user: user);
                            },
                          ),
                          GoRoute(
                            parentNavigatorKey: _rootNavigatorKey,
                            path: 'terminate',
                            builder: (context, state) {
                              final user = state.extra as User;
                              return TerminationScreen(user: user);
                            },
                          ),
                        ]),
                    GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        path: 'calculator',
                        builder: (context, state) => DailyIntakeScreen()),
                    GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        path: 'developer',
                        builder: (context, state) => DeveloperScreen()),
                  ]),
            ]),
          ],
        ),
      ]);
}

class _AppRouterRefreshStream extends ChangeNotifier {
  _AppRouterRefreshStream() {
    _checkTokens();
  }

  Future<void> _checkTokens() async {
    await Future.delayed(Duration(milliseconds: 100));
    notifyListeners();
  }
}
