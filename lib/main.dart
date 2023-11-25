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
    Key? key,
    required this.currentTheme,
    required Widget child,
    required this.toggleTheme,
  }) : super(key: key, child: child);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}

class _MainAppState extends State<MainApp> {
  // ThemeData currentTheme = DarkTheme.theme;
  ThemeData currentTheme = LightTheme.theme;

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      currentTheme: currentTheme,
      toggleTheme: () {
        setState(() {
          currentTheme = currentTheme == DarkTheme.theme
              ? LightTheme.theme
              : DarkTheme.theme;
        });
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode:
            currentTheme == DarkTheme.theme ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
