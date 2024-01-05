import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class User {
  String uid, id;
  String? email;
  double rank;
  int? last, signed;
  List<dynamic> favs;
  Map<String, dynamic> meta, pred;
  Image? profile, thumbnail;

  User({
    this.uid = '',
    this.id = '',
    this.email = '',
    this.rank = 1000,
    this.favs = const [],
    this.meta = const {},
    this.pred = const {},
    this.profile,
    this.thumbnail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'].toString(),
      email: json['email'].toString(),
      id: json['id'].toString(),
      favs: List.from(json['favs'].map((e) => Stock().fromCode(e))),
    );
  }

  @override
  String toString() {
    return jsonEncode({
      'uid': uid,
      'id': id,
      'favs': favs,
      'meta': meta,
    });
  }
}

class Log {
  Log._();
  static final Log _instance = Log._();
  factory Log() => _instance;
  User? user;
  bool get loggedin => user != null;

  Future<bool> login() async {
    try {
      print(await KakaoSdk.origin);
      await isKakaoTalkInstalled()
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      final kakao = await UserApi.instance.me();
      String uid = kakao.id.toString();
      int now = DateTime.now().millisecondsSinceEpoch;

      if (kakao.properties == null) return false;
      var meta = await Api().read(url: '/user/$uid/meta.json');
      var favs = await Api().read(url: '/user/$uid/favs.json');
      if (favs is Map<String, dynamic>) {
        favs = favs.keys.toList();
        await Api().fav(data: favs);
      }
      var pred = await Api().read(url: '/user/$uid/pred.json');

      var ac = kakao.kakaoAccount;
      var profileUrl = ac?.profile?.profileImageUrl;
      var thumbnailUrl = ac?.profile?.thumbnailImageUrl;

      var profile = await Api().image('/user/$uid/profile.png');
      var thumbnail = await Api().image('/user/$uid/thumbnail.png');
      if (profile == null && profileUrl != null) {
        await Api().save(
          url: '/user/$uid/profile.png',
          fileUrl: profileUrl,
        );
        profile = Image.network(profileUrl);
      }
      if (thumbnail == null && thumbnailUrl != null) {
        await Api().save(
          url: '/user/$uid/thumbnail.png',
          fileUrl: thumbnailUrl,
        );
        thumbnail = Image.network(thumbnailUrl);
      }
      if (meta.isEmpty) {
        await Api().write(
          url: '/user/$uid/meta.json',
          data: {
            'uid': uid,
            'id': ac?.profile?.nickname,
            'email': ac?.email,
            'signed': now,
            'last': now,
          },
        );
      } else {
        await Api().write(
          url: '/user/$uid/meta.json',
          data: {
            ...meta,
            'last': now,
          },
        );
      }
      user = User(
        uid: uid,
        email: ac?.email,
        id: meta?['id'] ?? ac?.profile?.nickname ?? uid,
        favs: favs
            .map((e) => Stock().hasCode(e) ? Stock().fromCode(e) : e)
            .toList(),
        profile: profile,
        thumbnail: thumbnail,
        pred: pred,
      );
      return true;
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      user = null;
      return true;
    } catch (error) {
      print('카카오톡으로 로그아웃 실패 $error');
      return false;
    }
  }
}
