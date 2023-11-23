import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Meta().load();

      Timer(const Duration(milliseconds: 1000), () {
        router.replace('/intro');
        // router.replace('/result');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.canvasColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 0,
            ),
            SvgPicture.asset(
              'svg.svg',
              width: 100,
              height: 100,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 10),
            Text(
              '오르고 떨어지고',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 3),
            Text(
              '오떨',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
