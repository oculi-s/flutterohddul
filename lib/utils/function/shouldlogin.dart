import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/base/list.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/svgloader.dart';

class LoginButton extends StatelessWidget {
  final ValueChanged callback;

  LoginButton({
    super.key,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).colorScheme.kakao,
        ),
      ),
      onPressed: () async {
        callback(await Log().login());
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgLoader.asset('assets/img/KakaoLogo.svg', height: 15),
          SizedBox(width: 3),
          Text(
            '카카오 로그인',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
          )
        ],
      ),
    );
  }
}

shouldLoginDialog(context, [callback]) {
  if (Log().loggedin) return false;
  var theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: theme.colorScheme.primary.darken(),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '로그인이 필요한 서비스입니다.',
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text('로그인하시면 다음의 서비스를 이용할 수 있습니다.'),
              BulletList(
                children: [
                  Text('2500개 종목의 주가 예측'),
                  Text('관심종목 설정과 편집'),
                  Text('의견게시판에 의견 올리기'),
                  Text('시황정보 모아보기'),
                ],
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: 10),
              LoginButton(
                callback: (v) {
                  if (v) {
                    router.pop();
                  }
                  if (callback != null) {
                    callback();
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
  return true;
}
