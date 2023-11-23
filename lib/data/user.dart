import 'dart:convert';
import 'dart:io';

import 'package:flutterohddul/data/element.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;

class User {
  final bool valid;
  String? uid;
  String? id;
  List<Stock>? favs;
  Map<String, dynamic>? meta;

  User({
    required this.valid,
    this.uid,
    this.id,
    this.favs,
    this.meta,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      valid: true,
      uid: json['uid'],
      id: json['id'],
      favs: List<Stock>.from(json['favs'].map((e) => Stock.fromCode(e))),
      meta: Map<String, dynamic>.from(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'uid': uid,
      'id': id,
      'favs': favs,
      'meta': meta,
    };
  }
}

class LoginUser {
  LoginUser._();
  static final LoginUser _instance = LoginUser._();
  factory LoginUser() => _instance;
  User user = User(valid: false);

  Future<void> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      final url = Uri.https('kapi.kakao.com', '/v2/user/me');
      final resp = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );
      final json = jsonDecode(resp as String);
      user = User.fromJson(json);
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
    }
  }

  Future<void> logout() async {
    await UserApi.instance.logout();
    user = User(valid: false);
  }
}
