import 'package:flutter/material.dart';
import 'package:flutterohddul/screen/profile.screen.dart';
import 'package:flutterohddul/screen/price.screen.dart';
import 'package:flutterohddul/screen/favs.screen.dart';
import 'package:flutterohddul/screen/market.screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(5),
          child: Center(
            child: [
              FavScreen(),
              const PriceScreen(),
              const Placeholder(),
              MarketScreen(),
              ProfileScreen(),
            ][i],
          ),
        ),
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
          onTap: (int _i) {
            setState(() {
              i = _i;
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
