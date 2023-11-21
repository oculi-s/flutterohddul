// import 'package:flutter/cupertino.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutterohddul/screen/profile.screen.dart';
// import 'package:flutterohddul/screen/price.screen.dart';

// final GoRouter router = GoRouter(
//   initialLocation: '/',
//   routes: <RouteBase>[
//     // GoRoute(
//     //   path: '/',
//     //   builder: (BuildContext context, GoRouterState state) {
//     //     return const SplashScreen();
//     //   },
//     // ),
//     // GoRoute(
//     //   path: '/intro',
//     //   pageBuilder: (context, state) {
//     //     return CustomTransitionPage(
//     //       child: const IntroScreen(),
//     //       transitionDuration: const Duration(milliseconds: 600),
//     //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//     //         return FadeTransition(
//     //           opacity: animation,
//     //           child: child,
//     //         );
//     //       },
//     //     );
//     //   },
//     //   builder: (BuildContext context, GoRouterState state) {
//     //     return const IntroScreen();
//     //   },
//     // ),
//     GoRoute(
//       path: '/profile/:uid',
//       pageBuilder: (context, state) {
//         String uid = state.pathParameters['uid'] ?? '';
//         return CustomTransitionPage(
//           child: ProfileScreen(
//             ,
//           ),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//               CupertinoPageTransition(
//             primaryRouteAnimation: animation,
//             secondaryRouteAnimation: secondaryAnimation,
//             linearTransition: false,
//             child: child,
//           ),
//         );
//       },
//     ),
//     // GoRoute(
//     //   path: '/result',
//     //   pageBuilder: (context, state) {
//     //     return CustomTransitionPage(
//     //       child: const ResultScreen(),
//     //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//     //           CupertinoPageTransition(
//     //         primaryRouteAnimation: animation,
//     //         secondaryRouteAnimation: secondaryAnimation,
//     //         linearTransition: false,
//     //         child: child,
//     //       ),
//     //     );
//     //   },
//     // ),
//   ],
// );
