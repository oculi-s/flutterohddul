import 'package:flutter/cupertino.dart';
import 'package:flutterohddul/screen/menu.screen.dart';
import 'package:flutterohddul/screen/splash.screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterohddul/screen/profile.screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/menu',
      // pageBuilder: (context, state) {
      //   return CustomTransitionPage(
      //     child: IntroScreen(),
      //     transitionDuration: const Duration(milliseconds: 600),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(
      //         opacity: animation,
      //         child: child,
      //       );
      //     },
      //   );
      // },
      builder: (BuildContext context, GoRouterState state) {
        return MenuScreen();
      },
    ),

    // GoRoute(
    //   path: '/price/:code',
    //   pageBuilder: (context, state) {
    //     String code = state.pathParameters['code'] ?? '';
    //     return CustomTransitionPage(
    //       child: PriceChart(),
    //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    //           CupertinoPageTransition(
    //         primaryRouteAnimation: animation,
    //         secondaryRouteAnimation: secondaryAnimation,
    //         linearTransition: false,
    //         child: child,
    //       ),
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/profile/:uid',
    //   pageBuilder: (context, state) {
    //     String uid = state.pathParameters['uid'] ?? '';
    //     return CustomTransitionPage(
    //       child: ProfileScreen(
    //         ,
    //       ),
    //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    //           CupertinoPageTransition(
    //         primaryRouteAnimation: animation,
    //         secondaryRouteAnimation: secondaryAnimation,
    //         linearTransition: false,
    //         child: child,
    //       ),
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/result',
    //   pageBuilder: (context, state) {
    //     return CustomTransitionPage(
    //       child: const ResultScreen(),
    //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    //           CupertinoPageTransition(
    //         primaryRouteAnimation: animation,
    //         secondaryRouteAnimation: secondaryAnimation,
    //         linearTransition: false,
    //         child: child,
    //       ),
    //     );
    //   },
    // ),
  ],
);
