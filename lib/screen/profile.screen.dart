import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/svgloader.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Log().user != null ? _logout() : _login(),
          Row(
            children: [
              Text('내 예측'),
              Text(Log().user?.pred.toString() ?? ''),
            ],
          )
        ],
      ),
    );
  }

  _login() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).colorScheme.kakao,
        ),
      ),
      onPressed: () async {
        await Log().login();
        setState(() {});
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgLoader.asset('assets/img/KakaoLogo.svg', height: 15),
          SizedBox(width: 3),
          Text(
            '카카오 로그인',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
          )
        ],
      ),
    );
  }

  _logout() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).colorScheme.kakao,
        ),
      ),
      onPressed: () async {
        await Log().logout();
        setState(() {});
      },
      child: Text('Logout'),
    );
  }
}
