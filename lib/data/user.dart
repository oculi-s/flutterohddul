import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;

class User {
  String? uid;
  String? id;
  String? email;
  double? rank;
  int? last, signed;
  List<dynamic>? favs;
  Map<String, dynamic>? meta;
  Image? profile, thumbnail;

  User({
    this.uid,
    this.id,
    this.email,
    this.favs,
    this.meta,
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

  Map<String, dynamic> toJson() {
    return {
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
  User user = User();
  bool valid = false;

  Future<void> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      final url = Uri.https('kapi.kakao.com', '/v2/user/me');
      final res = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );
      final uid = jsonDecode(res.body)?['id']?.toString();
      final json = jsonDecode(res.body)?['kakao_account'];
      final now = DateTime.now().millisecondsSinceEpoch;
      if (json == null) return;
      var meta = await Api().read(url: '/user/$uid/meta.json');
      var favs = await Api().read(url: '/user/$uid/favs.json');
      // var pred = await Api().read(url: '/user/$uid/pred.json');

      var profileUrl = json?['profile']?['profile_image_url'];
      var thumbnailUrl = json?['profile']?['thumbnail_image_url'];
      var profile = await Api().image('/user/$uid/profile.png');
      if (profile == null) {
        await Api().save(
          url: '/user/$uid/profile.png',
          fileUrl: profileUrl,
        );
        profile = Image.network(profileUrl);
      }
      var thumbnail = await Api().image('/user/$uid/thumbnail.png');
      if (thumbnail == null) {
        await Api().save(
          url: '/user/$uid/thumbnail.png',
          fileUrl: thumbnailUrl,
        );
        thumbnail = Image.network(thumbnailUrl);
      }
      if (meta.isNotEmpty) {
        await Api().write(
          url: '/user/$uid/meta.json',
          data: {
            'uid': uid,
            'id': json?['profile']?['nickname'],
            'email': json?['email'],
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
      valid = true;
      user = User(
        uid: uid,
        email: json?['email'],
        id: meta?['id'] ?? json?['profile']?['nickname'] ?? uid,
        favs: List<StockData>.from(favs.keys.map((e) => Stock().fromCode(e))),
        profile: profile,
        thumbnail: thumbnail,
        // pred:pred,
      );
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
    }
  }

  Future<void> logout() async {
    await UserApi.instance.logout();
    user = User();
    valid = false;
  }
}
