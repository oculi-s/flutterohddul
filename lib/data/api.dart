import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Meta {
  Meta._();
  static final Meta _instance = Meta._();
  factory Meta() => _instance;

  MetaData? aside;
  MetaData? market;
  MetaData? meta, group, indutyIndex, induty, price, hist;
  bool isDataLoaded() {
    return Meta().aside != null &&
        Meta().meta != null &&
        Meta().market != null &&
        Meta().group != null &&
        Meta().induty != null &&
        Meta().indutyIndex != null &&
        Meta().price != null;
  }

  Future<void> load() async {
    if (isDataLoaded()) return;
    aside = await MetaData.read('/meta/light/aside.json');
    meta = await MetaData.read('/meta/meta.json');
    market = await MetaData.read('/meta/light/market.json');
    group = await MetaData.read('/meta/light/group.json');
    induty = await MetaData.read('/meta/light/index.json');
    indutyIndex = await MetaData.read('/meta/light/induty.json');
    price = await MetaData.read('/meta/price.json');
    hist = await MetaData.read('/meta/hist.json');
  }
}

class MetaData {
  final bool? valid;
  final String? url;
  final int? last;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? index;

  MetaData({
    required this.valid,
    required this.url,
    required this.last,
    required this.data,
    required this.index,
  });

  static Future<MetaData> read(String url) async {
    final jsonData = await Api().read(url: url);
    return MetaData(
      valid: true,
      url: url,
      last: jsonData['last'] ?? 0,
      data: jsonData['data'] ?? jsonData,
      index: jsonData['index'] ?? {},
    );
  }
}

class Api {
  Api._();
  static final Api _instance = Api._();
  factory Api() => _instance;

  Future<dynamic> read({
    String? url,
    Stock? stock,
  }) async {
    final apiUrl = Uri.parse('https://api.ohddul.com/read');
    String entry() {
      if (url != null) {
        return url;
      } else if (stock != null && stock.valid) {
        return '/stock/${stock.code}/price.json';
      }
      return '';
    }

    try {
      final res = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiKey': Env.ohddulApi,
          'url': entry(),
        }),
      );
      if (res.statusCode == 200) {
        final data = utf8.decode(res.bodyBytes);
        final jsonData = json.decode(data);
        return jsonData;
      } else {
        print('Failed to load data. Status code: ${res.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error loading data: $e');
      return {};
    }
  }

  Future<bool> write({
    String? url,
    Map<String, dynamic>? data,
  }) async {
    final apiUrl = Uri.parse('https://api.ohddul.com/write');
    try {
      if (url == null && data == null) return false;
      final res = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiKey': Env.ohddulApi,
          'url': url.toString(),
          'data': jsonEncode(data),
        }),
      );
      if (res.statusCode == 200) {
        return true;
      } else {
        print('Failed to write data. Status code: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error writing data: $e');
      return false;
    }
  }

  Future<bool> save({
    String? url,
    String? fileUrl,
  }) async {
    final apiUrl = Uri.parse('https://api.ohddul.com/save');
    try {
      if (url == null && fileUrl == null) return false;
      final res = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiKey': Env.ohddulApi,
          'url': url.toString(),
          'fileUrl': fileUrl.toString(),
        }),
      );
      if (res.statusCode == 200) {
        print('File uploaded');
        return true;
      } else {
        print('Failed to upload data. Status code: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error upload data: $e');
      return false;
    }
  }

  Future<dynamic> image(
    String? url,
  ) async {
    final apiUrl = Uri.parse('https://api.ohddul.com/read');
    final res = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'apiKey': Env.ohddulApi,
        'url': url.toString(),
      }),
    );
    if (res.statusCode == 200) {
      return Image.memory(res.bodyBytes);
    } else {
      return null;
    }
  }
}
