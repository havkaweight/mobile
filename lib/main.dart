
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/theme.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/chat_screen.dart';
import 'package:havka/ui/screens/chats_list_screen.dart';
import 'package:havka/ui/screens/daily_intake_screen.dart';
import 'package:havka/ui/screens/developer_screen.dart';
import 'package:havka/ui/screens/error_screen.dart';
import 'package:havka/ui/screens/fridge_adjustment_screen.dart';
import 'package:havka/ui/screens/fridge_screen.dart';
import 'package:havka/ui/screens/intake_screen.dart';
import 'package:havka/ui/screens/main_screen.dart';
import 'package:havka/ui/screens/profile_edit_screen.dart';
import 'package:havka/ui/screens/profile_screen.dart';
import 'package:havka/ui/screens/scale_screen.dart';
import 'package:havka/ui/screens/sign_in_screen.dart';
import 'package:havka/ui/screens/splash_screen.dart';
import 'package:havka/ui/screens/stats_screen.dart';
import 'package:havka/ui/screens/story_screen.dart';
import 'package:havka/ui/screens/termination_screen.dart';
import 'package:havka/ui/screens/username_change_screen.dart';
import 'package:provider/provider.dart';

import 'components/push_notifications_listener.dart';
import 'model/auth_data_model.dart';
import 'model/fridge.dart';
import 'model/fridge_data_model.dart';
import 'model/profile_data_model.dart';
import 'model/user.dart';
import 'model/user_data_model.dart';
import 'model/user_profile.dart';
import 'model/weight_history.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _statsNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _fridgeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  runApp(
    HavkaApp(),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print(message.data);
  if (message.data.isEmpty) {
    return;
  }

  if (message.data["action"] == "VIEW_PROFILE") {
    router.go(message.data["deep_link"]);
  }
}


Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a foreground message: ${message.messageId}");
  print(message.data);
  if (message.data.isEmpty) {
    return;
  }

  if (message.data["action"] == "VIEW_PROFILE") {
    router.go(message.data["deep_link"]);
    return;
  }
}

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      redirect: (_, __) => "/splash",
    ),
    GoRoute(
      path: "/splash",
      builder: (_, __) => SplashScreen(),
      redirect: (context, state) {
        final auth = context.watch<AuthDataModel>();
        if (auth.isAuthorized == null) {
          return "/splash";
        }
        if (auth.isAuthorized!) {
          return "/fridge";
        }
        return "/login";
      },
    ),
    GoRoute(
      path: "/login",
      pageBuilder: (_, __) {
        return CustomTransitionPage(
          transitionsBuilder:
              (context, animation, secondAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: SignInScreen(),
        );
      },
    ),
    GoRoute(
      path: "/about",
      builder: (_, __) => StoryPage(),
    ),
    StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state, navigationShell) {
          return CustomTransitionPage(
              transitionsBuilder:
                  (context, animation, secondAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: MainScreen(
                navigationShell: navigationShell,
              )
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _statsNavigatorKey,
            routes: [
              GoRoute(
                path: "/stats",
                pageBuilder: (context, __) {
                  context.read<WeeklyProgressDataModel>().initData();
                  context.read<DailyProgressDataModel>().initData();
                  return CustomTransitionPage(
                    transitionsBuilder:
                        (context, animation, secondAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: StatsScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: "intake",
                    builder: (_, __) =>
                        IntakeScreen(),
                  ),
                ]
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _fridgeNavigatorKey,
            routes: [
              GoRoute(
                  path: "/fridge",
                  pageBuilder: (context, __) {
                    context.read<FridgeDataModel>().initData();
                    return CustomTransitionPage(
                      transitionsBuilder:
                          (context, animation, secondAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: FridgeScreen(),
                    );
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "add",
                      builder: (_, __) =>
                          FridgeAdjustmentScreen(),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "edit",
                      builder: (_, state) =>
                          FridgeAdjustmentScreen(userFridge: state.extra as UserFridge),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: ":fridge_item_id",
                      builder: (_, state) =>
                          ScaleScreen(userProduct: state.extra as UserFridgeItem),
                    ),
                  ]
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                  path: "/profile",
                  pageBuilder: (context, __) {
                    context.read<UserDataModel>().initData();
                    context.read<WeightHistoryDataModel>().initData();
                    return CustomTransitionPage(
                      transitionsBuilder:
                          (context, animation, secondAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: ProfileScreen(),
                    );
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "developer",
                      builder: (_, __) =>
                          DeveloperScreen(),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "chat",
                      builder: (_, state) => ChatScreen(),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "chats",
                      builder: (_, state) => ChatsListScreen(),
                      routes: [
                        GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: "chat",
                          builder: (_, state) => ChatScreen(user: state.extra as String?),
                        ),
                      ],
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "calculator",
                      builder: (_, state) => DailyIntakeScreen(weight: state.extra as double),
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: "edit",
                      pageBuilder: (_, state) {
                        final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
                        return CustomTransitionPage(
                          transitionsBuilder:
                              (context, animation, secondAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: ProfileEditingScreen(
                            user: args["user"] as User,
                            userProfile: args["user_profile"] as UserProfile,
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: "username",
                          pageBuilder: (_, state) => CustomTransitionPage(
                            transitionsBuilder:
                                (context, animation, secondAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: UsernameChangeScreen(user: state.extra as User),
                          ),
                        ),
                        GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: "terminate",
                          pageBuilder: (_, state) => CustomTransitionPage(
                            transitionsBuilder:
                                (context, animation, secondAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: TerminationScreen(user: state.extra as User),
                          ),
                        ),
                      ],
                    ),
                  ])
            ],
          ),
        ]
    ),
  ],
  errorPageBuilder: (_, __) => CustomTransitionPage(
    transitionsBuilder:
        (context, animation, secondAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    child: ErrorScreen(),
  ),
);

class HavkaApp extends StatefulWidget {
  @override
  _HavkaAppState createState() => _HavkaAppState();
}

class _HavkaAppState extends State<HavkaApp> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.dark,
    );

    final AuthDataModel authDataModel = AuthDataModel();

    final UserDataModel userDataModel = UserDataModel();
    final ProfileDataModel profileDataModel = ProfileDataModel();
    final FridgeDataModel fridgeDataModel = FridgeDataModel();

    final DailyProgressDataModel dailyProgressDataModel = DailyProgressDataModel();
    final WeeklyProgressDataModel weeklyProgressDataModel = WeeklyProgressDataModel();
    final WeightHistoryDataModel weightHistoryDataModel = WeightHistoryDataModel();

    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (BuildContext context) => authDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => weeklyProgressDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => weightHistoryDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => dailyProgressDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => userDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => profileDataModel),
      ChangeNotifierProvider(
          create: (BuildContext context) => fridgeDataModel),
    ], child: MaterialApp.router(
        routerConfig: router,
        theme: themeData,
      ),
    );
  }
}