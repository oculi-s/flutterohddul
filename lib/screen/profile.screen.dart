import 'package:flutter/material.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/function/shouldlogin.dart';

class Profile extends StatelessWidget {
  final User user;
  const Profile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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
          Card(child: Text(Log().user?.id ?? '')),
          Row(
            children: [
              Text(Log().user?.id ?? ''),
            ],
          ),
          Row(
            children: [
              const Text('내 예측'),
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
      child: const Text('Logout'),
    );
  }
}
