import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/api.dart';

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

      Timer(const Duration(milliseconds: 2500), () {
        router.replace('/intro');
        // router.replace('/result');
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 36,
          ),
          child: Stack(
            children: [
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
              ),
              Text('ohddul'),
            ],
          ),
        ),
      ),
    );
  }
}
