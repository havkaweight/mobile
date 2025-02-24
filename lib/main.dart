import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/data/api/endpoints.dart';
import 'package:havka/data/api/token_storage.dart';
import 'package:havka/domain/repositories/product/product_repository.dart';
import 'package:havka/presentation/providers/consumption_provider.dart';
import 'package:havka/presentation/providers/fridge_provider.dart';
import 'package:havka/presentation/providers/health_provider.dart';
import 'package:havka/presentation/providers/product_provider.dart';
import 'package:havka/presentation/providers/profile_provider.dart';
import 'package:havka/presentation/providers/user_provider.dart';
import '/core/constants/theme.dart';
import '/presentation/screens/stats_screen.dart';
import 'package:provider/provider.dart';
import 'core/routes.dart';
import 'data/api/api_service.dart';
import 'data/api/auth_api_service.dart';
import 'data/repositories/auth/auth_repository_impl.dart';
import 'data/repositories/consumption/consumption_repository_impl.dart';
import 'data/repositories/fridge/fridge_repository_impl.dart';
import 'data/repositories/health/health_repository_impl.dart';
import 'data/repositories/product/product_repository_impl.dart';
import 'data/repositories/profile/profile_repository_impl.dart';
import 'data/repositories/user/user_repository_impl.dart';
import 'domain/repositories/consumption/consumption_repository.dart';
import 'domain/repositories/fridge/fridge_repository.dart';
import 'domain/repositories/profile/profile_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'domain/repositories/auth/auth_repository.dart';
import 'domain/repositories/user/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    debugPrint("🔥 Firebase initialization failed: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

  runApp(HavkaApp());
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
    AppRouter.router.go(message.data["deep_link"]);
  }
}


Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase repositories in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase repositories.
  await Firebase.initializeApp();

  print("Handling a foreground message: ${message.messageId}");
  print(message.data);
  if (message.data.isEmpty) {
    return;
  }

  if (message.data["action"] == "VIEW_PROFILE") {
    AppRouter.router.go(message.data["deep_link"]);
    return;
  }
}

// final GoRouter router = GoRouter(
//   navigatorKey: _rootNavigatorKey,
//   initialLocation: "/",
//   routes: [
//     GoRoute(
//       path: "/",
//       redirect: (_, __) => "/splash",
//     ),
//     GoRoute(
//       path: "/splash",
//       builder: (_, __) => SplashScreen(),
//       redirect: (context, state) {
//         final auth = context.watch<AuthProvider>();
//         if (auth.isLoading) {
//           return "/splash";
//         }
//         if (auth.isAuthenticated) {
//           return "/fridge";
//         }
//         return "/login";
//       },
//     ),
//     GoRoute(
//       path: "/login",
//       pageBuilder: (_, __) {
//         return CustomTransitionPage(
//           transitionsBuilder:
//               (context, animation, secondAnimation, child) {
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//           child: AuthScreen(),
//         );
//       },
//     ),
//     GoRoute(
//       path: "/about",
//       builder: (_, __) => StoryPage(),
//     ),
//     StatefulShellRoute.indexedStack(
//         parentNavigatorKey: _rootNavigatorKey,
//         pageBuilder: (_, state, navigationShell) {
//           return CustomTransitionPage(
//               transitionsBuilder:
//                   (context, animation, secondAnimation, child) {
//                 return FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 );
//               },
//               child: MainScreen()
//           );
//         },
//         branches: [
//           StatefulShellBranch(
//             navigatorKey: _statsNavigatorKey,
//             routes: [
//               GoRoute(
//                 path: "/stats",
//                 pageBuilder: (context, __) {
//                   context.read<WeeklyProgressDataModel>().initData();
//                   context.read<DailyProgressDataModel>().initData();
//                   return CustomTransitionPage(
//                     transitionsBuilder:
//                         (context, animation, secondAnimation, child) {
//                       return FadeTransition(
//                         opacity: animation,
//                         child: child,
//                       );
//                     },
//                     child: StatsScreen(),
//                   );
//                 },
//                 routes: [
//                   GoRoute(
//                     parentNavigatorKey: _rootNavigatorKey,
//                     path: "intake",
//                     builder: (_, __) =>
//                         IntakeScreen(),
//                   ),
//                 ]
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             navigatorKey: _fridgeNavigatorKey,
//             routes: [
//               GoRoute(
//                   path: "/fridge",
//                   pageBuilder: (context, __) {
//                     final FridgeProvider fridgeProvider = context.read<FridgeProvider>();
//                     fridgeProvider.fetchFridges();
//                     fridgeProvider.fetchFridgeItems();
//                     return CustomTransitionPage(
//                       transitionsBuilder:
//                           (context, animation, secondAnimation, child) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: child,
//                         );
//                       },
//                       child: FridgeScreen(),
//                     );
//                   },
//                   routes: [
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "add",
//                       builder: (_, __) =>
//                           FridgeAdjustmentScreen(),
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "edit",
//                       builder: (_, state) =>
//                           FridgeAdjustmentScreen(userFridge: state.extra as UserFridge),
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: ":fridge_item_id",
//                       builder: (_, state) =>
//                           ScaleScreen(userProduct: state.extra as FridgeItem),
//                     ),
//                   ]
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             navigatorKey: _profileNavigatorKey,
//             routes: [
//               GoRoute(
//                   path: "/profile",
//                   pageBuilder: (context, __) {
//                     final UserProvider userProvider = context.read<UserProvider>();
//                     context.read<WeightHistoryDataModel>().initData();
//                     return CustomTransitionPage(
//                       transitionsBuilder:
//                           (context, animation, secondAnimation, child) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: child,
//                         );
//                       },
//                       child: ProfileScreen(),
//                     );
//                   },
//                   routes: [
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "developer",
//                       builder: (_, __) =>
//                           DeveloperScreen(),
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "chat",
//                       builder: (_, state) => ChatScreen(),
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "chats",
//                       builder: (_, state) => ChatsListScreen(),
//                       routes: [
//                         GoRoute(
//                           parentNavigatorKey: _rootNavigatorKey,
//                           path: "chat",
//                           builder: (_, state) => ChatScreen(user: state.extra as String?),
//                         ),
//                       ],
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "calculator",
//                       builder: (_, state) => DailyIntakeScreen(weight: state.extra as double),
//                     ),
//                     GoRoute(
//                       parentNavigatorKey: _rootNavigatorKey,
//                       path: "edit",
//                       pageBuilder: (_, state) {
//                         final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
//                         return CustomTransitionPage(
//                           transitionsBuilder:
//                               (context, animation, secondAnimation, child) {
//                             return FadeTransition(
//                               opacity: animation,
//                               child: child,
//                             );
//                           },
//                           child: ProfileEditingScreen(
//                             user: args["user"] as User,
//                             profile: args["user_profile"] as Profile,
//                           ),
//                         );
//                       },
//                       routes: [
//                         GoRoute(
//                           parentNavigatorKey: _rootNavigatorKey,
//                           path: "username",
//                           pageBuilder: (_, state) => CustomTransitionPage(
//                             transitionsBuilder:
//                                 (context, animation, secondAnimation, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                             child: UsernameChangeScreen(user: state.extra as User),
//                           ),
//                         ),
//                         GoRoute(
//                           parentNavigatorKey: _rootNavigatorKey,
//                           path: "terminate",
//                           pageBuilder: (_, state) => CustomTransitionPage(
//                             transitionsBuilder:
//                                 (context, animation, secondAnimation, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                             child: TerminationScreen(user: state.extra as User),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ])
//             ],
//           ),
//         ]
//     ),
//   ],
//   errorPageBuilder: (_, __) => CustomTransitionPage(
//     transitionsBuilder:
//         (context, animation, secondAnimation, child) {
//       return FadeTransition(
//         opacity: animation,
//         child: child,
//       );
//     },
//     child: ErrorScreen(),
//   ),
// );

class HavkaApp extends StatefulWidget {
  @override
  _HavkaAppState createState() => _HavkaAppState();
}

class _HavkaAppState extends State<HavkaApp> {
  @override
  void initState() {
    super.initState();
    // _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialLink = Uri.base.toString();
      if (initialLink.isNotEmpty) {
        context.pushNamed(initialLink.replaceFirst(Endpoints.host, ''));
        // Navigator.pushNamed(context, initialLink.replaceFirst(Endpoints.host, ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.dark,
    );

    final AuthApiService authApiService = AuthApiService(baseUrl: Endpoints.host);
    final authRepository = AuthRepositoryImpl(authApiService: authApiService, tokenStorage: TokenStorage());
    final ApiService apiService = ApiService(baseUrl: '${Endpoints.host}${Endpoints.prefix}', authRepository: authRepository);

    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(authApiService: authApiService, tokenStorage: TokenStorage()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(repository: context.read<AuthRepository>()),
        ),

        Provider<UserRepository>(
          create: (_) => UserRepositoryImpl(apiService: apiService),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(repository: context.read<UserRepository>()),
        ),

        Provider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(authRepository, apiService: apiService),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(repository: context.read<ProfileRepository>()),
        ),

        Provider<ProductRepository>(
            create: (_) => ProductRepositoryImpl(apiService: apiService),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(repository: context.read<ProductRepository>()),
        ),

        Provider<FridgeRepository>(
            create: (_) => FridgeRepositoryImpl(apiService: apiService),
        ),
        ChangeNotifierProvider<FridgeProvider>(
          create: (context) => FridgeProvider(fridgeRepository: context.read<FridgeRepository>()),
        ),

        Provider<ConsumptionRepository>(
            create: (_) => ConsumptionRepositoryImpl(apiService: apiService),
        ),
        ChangeNotifierProvider<ConsumptionProvider>(
          create: (context) => ConsumptionProvider(repository: context.read<ConsumptionRepository>()),
        ),

        ChangeNotifierProvider(
            create: (_) => HealthProvider(HealthRepositoryImpl())
        ),

      ],
      // child: MaterialApp(
      //   title: 'Havka',
      //   theme: themeData,
      //   initialRoute: AppRoutes.home,
      //   onGenerateRoute: AppRoutes.generateRoute,
      // ),
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        theme: themeData,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}