import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';

class MenuScreen extends StatefulWidget {
  final int? i;
  final Widget child;
  final AppBar? appBar;
  const MenuScreen({
    super.key,
    required this.child,
    this.i,
    this.appBar,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int i = 0;
  final _href = [
    '/favs',
    '/chart/005930',
    '/community',
    '/market',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    i = widget.i ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.appBar,
        body: SingleChildScrollView(child: Center(child: widget.child)),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: i == 0
                    ? const Icon(Icons.star_rounded)
                    : const Icon(Icons.star_border_rounded),
                label: '즐겨찾기'),
            BottomNavigationBarItem(
                icon: i == 1
                    ? const Icon(Icons.insert_chart_rounded)
                    : const Icon(Icons.insert_chart_outlined_rounded),
                label: '현재가'),
            BottomNavigationBarItem(
                icon: i == 2
                    ? const Icon(Icons.shopping_bag)
                    : const Icon(Icons.shopping_bag_outlined),
                label: '커뮤니티'),
            BottomNavigationBarItem(
                icon: i == 3
                    ? const Icon(Icons.movie)
                    : const Icon(Icons.movie_outlined),
                label: '시황'),
            BottomNavigationBarItem(
                icon: i == 4
                    ? const Icon(Icons.person)
                    : const Icon(Icons.person_outline),
                label: '프로필')
          ],
          currentIndex: i,
          selectedItemColor: Theme.of(context).colorScheme.tertiary,
          unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onTap: (int index) {
            setState(() {
              i = index;
              router.go(_href[i]);
            });
          },
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
