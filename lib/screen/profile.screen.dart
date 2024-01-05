import 'package:flutter/material.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/function/shouldlogin.dart';

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
          Log().loggedin
              ? _logout()
              : LoginButton(callback: (v) {
                  if (v) {
                    setState() {}
                  }
                }),
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
