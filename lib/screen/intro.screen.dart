import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterohddul/core/login.dart';
import 'package:flutterohddul/screen/chart.price.screen.dart';
import 'package:flutterohddul/screen/profile.screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  static const String _title = 'Ohddul';
  bool themeIsDark = true;
  bool isLoggedIn = false;

  void updateTheme(bool newTheme) {
    setState(() {
      themeIsDark = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeIsDark ? ThemeData.dark() : ThemeData.light(),
      title: _title,
      home: BottomNavigator(
        themeIsDark: themeIsDark,
        updateTheme: updateTheme,
        isLoggedIn: isLoggedIn,
      ),
    );
  }
}

class BottomNavigator extends StatefulWidget {
  final bool themeIsDark;
  final bool isLoggedIn;
  final Function(bool) updateTheme;

  const BottomNavigator({
    required this.themeIsDark,
    required this.updateTheme,
    required this.isLoggedIn,
  });

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  late TextEditingController codeController;
  late List<Widget> _widgetOptions;
  int _selectedIndex = 0;
  String? _stockCode;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCodeChanged(String code) {
    codeController.clear();
    setState(() {
      _widgetOptions[1] = PriceChart(code: code);
      _stockCode = code;
    });
  }

  @override
  void initState() {
    super.initState();
    _stockCode ??= '005930';
    codeController = TextEditingController();
    _widgetOptions = [
      Text('home'),
      PriceChart(code: _stockCode!),
      Placeholder(),
      Placeholder(),
      LoginScreen(),
      // widget.isLoggedIn ? Placeholder() : LoginScreen(),
      // widget.isLoggedIn ? ProfileScreen() : LoginScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: codeController,
          onSubmitted: _onCodeChanged,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(
                r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]')),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.updateTheme(!widget.themeIsDark);
              });
            },
            icon: Icon(
              widget.themeIsDark
                  ? Icons.wb_sunny_sharp
                  : Icons.nightlight_round_outlined,
            ),
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Icon(Icons.home_filled, color: Colors.black)
                  : Icon(Icons.home_outlined, color: Colors.black),
              label: 'home'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Icon(Icons.search, color: Colors.black)
                  : Icon(Icons.search_off, color: Colors.black),
              label: 'search'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Icon(Icons.shopping_bag, color: Colors.black)
                  : Icon(Icons.shopping_bag_outlined, color: Colors.black),
              label: 'media'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Icon(Icons.movie, color: Colors.black)
                  : Icon(Icons.movie_outlined, color: Colors.black),
              label: 'shop'),
          BottomNavigationBarItem(
              icon: _selectedIndex == 4
                  ? Icon(Icons.person, color: Colors.black)
                  : Icon(Icons.person_outline, color: Colors.black),
              label: 'profile')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        showSelectedLabels: false, //(1)
        showUnselectedLabels: false, //(1)
        type: BottomNavigationBarType.fixed, //(2)
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return DefaultTabController(
  //     initialIndex: 0,
  //     length: 5,
  //     child: Scaffold(
  //       ,
  //       bottomNavigationBar: TabBar(
  //         tabs: _widgetIcons,
  //         indicatorColor: Colors.transparent,
  //         unselectedLabelColor: Colors.grey,
  //         labelColor: Colors.black,
  //       ),
  //       body: TabBarView(
  //         children: _widgetOptions,
  //       ),
  //     ),
  //   );
  // }
}
