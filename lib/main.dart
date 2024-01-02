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
  const MainApp({super.key});

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
  late Brightness brightness;

  @override
  void initState() {
    super.initState();
  }

  ThemeMode get themeMode =>
      brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    brightness = MediaQuery.of(context).platformBrightness;
    return ThemeProvider(
      currentTheme: MyTheme(brightness: brightness).theme,
      toggleTheme: () {
        setState(() {
          brightness = brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark;
        });
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: MyTheme(brightness: brightness).theme,
        themeMode: themeMode,
      ),
    );
  }
}
