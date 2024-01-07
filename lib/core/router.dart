import 'package:flutter/cupertino.dart';
import 'package:flutterohddul/external/stock.dart';
import 'package:flutterohddul/screen/favs.screen.dart';
import 'package:flutterohddul/screen/market.screen.dart';
import 'package:flutterohddul/screen/menu.screen.dart';
import 'package:flutterohddul/screen/price.screen.dart';
import 'package:flutterohddul/screen/profile.screen.dart';
import 'package:flutterohddul/screen/splash.screen.dart';
import 'package:go_router/go_router.dart';

Widget _transition(context, animation, secondaryAnimation, child) =>
    CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    );

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
      path: '/favs',
      builder: (BuildContext context, GoRouterState state) {
        return const MenuScreen(
          i: 0,
          child: FavScreen(),
        );
      },
    ),
    GoRoute(
      path: '/chart/:code',
      builder: (context, state) {
        String code = state.pathParameters['code'] ?? '005930';
        return MenuScreen(
          i: 1,
          child: PriceScreen(code: code),
        );
      },
    ),
    GoRoute(
      path: '/market',
      builder: (context, state) {
        return const MenuScreen(
          i: 3,
          child: MarketScreen(),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: MenuScreen(
            i: 4,
            child: ProfileScreen(),
          ),
          transitionsBuilder: _transition,
        );
      },
    ),
    GoRoute(
      path: '/stock/:code',
      builder: (context, state) {
        String? code = state.pathParameters['code'];
        return StockExternal(code: code);
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
