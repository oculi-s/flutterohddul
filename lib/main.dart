import 'package:flutter/material.dart';
import 'package:flutterohddul/core/login.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/screen/profile.screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutterohddul/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: Env.kakaoNative,
    javaScriptAppKey: Env.kakaoJS,
  );

  await Meta().load();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  BottomNavigator({
    required this.themeIsDark,
    required this.updateTheme,
    required this.isLoggedIn,
  });
  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final List<Widget> _widgetOptions = [
    Text('home'),
    Placeholder(),
    Placeholder(),
    Placeholder(),
    LoginScreen(),
    // isLoggedIn ? ProfileScreen() : LoginScreen(),
  ];

  final List<Widget> _widgetIcons = [
    Tab(icon: Icon(Icons.home_outlined)),
    Tab(icon: Icon(Icons.search)),
    Tab(icon: Icon(Icons.movie_outlined)),
    Tab(icon: Icon(Icons.shopping_bag_outlined)),
    Tab(icon: Icon(Icons.person_outline)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Ohddul"),
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
        bottomNavigationBar: TabBar(
          tabs: _widgetIcons,
          indicatorColor: Colors.transparent,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.black,
        ),
        body: TabBarView(
          children: _widgetOptions,
        ),
      ),
    );
  }
}
