import 'dart:convert';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/env/env.dart';
import 'package:http/http.dart' as http;

class Meta {
  Meta._();
  static final Meta _instance = Meta._();
  factory Meta() => _instance;

  MetaData? aside;
  MetaData? market;
  MetaData? meta, group, indutyIndex, induty;
  bool isDataLoaded() {
    return Meta().aside != null &&
        Meta().meta != null &&
        Meta().market != null &&
        Meta().group != null &&
        Meta().induty != null &&
        Meta().indutyIndex != null;
  }

  Future<void> load() async {
    if (isDataLoaded()) return;
    aside = await MetaData.read('/meta/light/aside.json');
    meta = await MetaData.read('/meta/meta.json');
    market = await MetaData.read('/meta/light/market.json');
    group = await MetaData.read('/meta/light/group.json');
    induty = await MetaData.read('/meta/light/index.json');
    indutyIndex = await MetaData.read('/meta/light/induty.json');
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
      data: jsonData['data'] ?? {},
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
      } else if (stock != null) {
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
        jsonData['valid'] = true;
        return jsonData;
      } else {
        print('Failed to load data. Status code: ${res.statusCode}');
        return {'valid': false};
      }
    } catch (e) {
      print('Error loading data: $e');
      return {'valid': false};
    }
  }
}
