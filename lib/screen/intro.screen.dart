import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterohddul/core/colors.dart';
import 'package:flutterohddul/core/login.dart';
import 'package:flutterohddul/screen/chart.price.screen.dart';
import 'package:flutterohddul/screen/favs.screen.dart';
import 'package:flutterohddul/screen/profile.screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    FavScreen(),
    const PriceScreen(),
    const Placeholder(),
    const Placeholder(),
    const LoginScreen(),
    // widget.isLoggedIn ? Placeholder() : LoginScreen(),
    // widget.isLoggedIn ? ProfileScreen() : LoginScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? const Icon(Icons.star_rounded)
                  : const Icon(Icons.star_border_rounded),
              label: '즐겨찾기'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? const Icon(Icons.insert_chart_rounded)
                  : const Icon(Icons.insert_chart_outlined_rounded,
                      color: Colors.black),
              label: 'search'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? const Icon(Icons.shopping_bag)
                  : const Icon(Icons.shopping_bag_outlined,
                      color: Colors.black),
              label: 'media'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? const Icon(Icons.movie)
                  : const Icon(Icons.movie_outlined),
              label: 'shop'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 4
                  ? const Icon(Icons.person)
                  : const Icon(Icons.person_outline),
              label: 'profile')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.blue,
        onTap: _onItemTapped,
        showSelectedLabels: true, //(1)
        showUnselectedLabels: true, //(1)
        type: BottomNavigationBarType.fixed, //(2)
      ),
    );
  }
}
