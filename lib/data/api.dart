import 'dart:convert';
import 'package:flutterohddul/env/env.dart';
import 'package:http/http.dart' as http;

class Meta {
  Meta._();
  static final Meta _instance = Meta._();
  factory Meta() => _instance;

  Data? aside;
  Future<void> load() async {
    aside = await Data.read('/meta/light/aside.json');
  }
}

class Data {
  final bool valid;
  final String url;
  final int last;
  final Map<String, dynamic> data;

  Data({
    required this.valid,
    required this.url,
    required this.last,
    required this.data,
  });

  static Future<Data> read(String url) async {
    final apiUrl = Uri.parse('https://api.ohddul.com/read');
    final apiKey = Env.ohddulApi; // 여기에 실제 API 키를 추가하세요
    try {
      final res = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiKey': apiKey,
          'url': url,
        }),
      );
      if (res.statusCode == 200) {
        final data = utf8.decode(res.bodyBytes);
        print('${url} Loaded');
        final jsonData = json.decode(data);
        return Data(
          valid: true,
          url: url,
          last: jsonData['last'],
          data: jsonData['data'],
        );
      } else {
        return Data(valid: false, url: url, last: 0, data: {});
      }
    } catch (e) {
      return Data(valid: false, url: url, last: 0, data: {});
    }
  }
}
