import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:flutterohddul/data/prediction.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:flutterohddul/utils/svgloader.dart';

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
      await Market().load();
      await Group().load();
      await Induty().load();
      await Pred().count.load();
      router.replace('/favs');
      // Timer(const Duration(milliseconds: 1000), () {
      // });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Screen(context).w,
              height: 0,
            ),
            SvgLoader.asset(
              'assets/svg.svg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 10),
            Text(
              '오르고 떨어지고',
              style: theme.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              '오떨',
              style: theme.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
