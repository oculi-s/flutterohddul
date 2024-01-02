import 'package:flutter/material.dart';
import 'package:flutterohddul/core/colors.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutterohddul/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: Env.kakaoNative,
    javaScriptAppKey: Env.kakaoJS,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class ThemeProvider extends InheritedWidget {
  final ThemeData currentTheme;
  final Function() toggleTheme;

  const ThemeProvider({
    super.key,
    required this.currentTheme,
    required Widget child,
    required this.toggleTheme,
  }) : super(child: child);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}

class _MainAppState extends State<MainApp> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      currentTheme:
          themeMode == ThemeMode.dark ? DarkTheme.theme : LightTheme.theme,
      toggleTheme: () {
        setState(() {
          themeMode =
              themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        });
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: themeMode,
      ),
    );
  }
}
