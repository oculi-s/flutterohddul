import 'package:flutter/material.dart';
import 'package:flutterohddul/data/user.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  bool isLoggedIn = LoginUser().valid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggedIn ? logoutScreen() : loginScreen(),
    );
  }

  loginScreen() {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await LoginUser().login();
            setState(() {
              isLoggedIn = LoginUser().valid;
            });
          },
          child: Text('Login with Kakao'),
        ),
      ),
    );
  }

  logoutScreen() {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await LoginUser().logout();
            setState(() {
              isLoggedIn = LoginUser().valid;
            });
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
