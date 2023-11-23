import 'package:flutter/material.dart';
import 'package:flutterohddul/core/colors.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutterohddul/env/env.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: Env.kakaoNative,
    javaScriptAppKey: Env.kakaoJS,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class ThemeProvider extends InheritedWidget {
  final bool themeIsDark;
  final Function() toggleTheme;
  final bool isLoggedIn;

  const ThemeProvider({
    Key? key,
    required this.themeIsDark,
    required Widget child,
    required this.toggleTheme,
    required this.isLoggedIn,
  }) : super(key: key, child: child);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeIsDark != oldWidget.themeIsDark ||
        isLoggedIn != oldWidget.isLoggedIn;
  }
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    bool themeIsDark = true;
    bool isLoggedIn = false;
    return ThemeProvider(
      themeIsDark: themeIsDark,
      toggleTheme: () {
        setState(() {
          themeIsDark = !themeIsDark;
        });
      },
      isLoggedIn: isLoggedIn,
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: DarkTheme.getTheme(),
        darkTheme: LightTheme.getTheme(),
        themeMode: themeIsDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
