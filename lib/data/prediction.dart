import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/extension.dart';

class Pred {
  Pred._();
  static final Pred _instance = Pred._();
  factory Pred() => _instance;

  PredCount count = PredCount();

  Future<void> add(
    BuildContext context,
    StockData stock, [
    bool up = true,
  ]) async {
    var uid = Log().user!.uid;
    var pred = PredQueueItem(
      code: stock.code,
      fromPrice: stock.lastPrice,
      predicted: DateTime.now(),
      uid: uid,
      up: up,
    );
    await count.add(code: stock.code, up: up);
    Log().user!.pred.add(pred);
    var stockpred = await Api().read(url: '/pred/${stock.code}.json');
    if (stockpred['queue'] == null) stockpred['queue'] = [];
    if (stockpred['data'] == null) stockpred['data'] = [];
    stockpred['queue'].add(pred.toJson());
    await Api().write(url: '/pred/${stock.code}.json', data: stockpred);
  }
}

class PredCount {
  var data = {};

  PredCount();
  Future<void> load() async {
    data = await Api().read(url: '/meta/pred.json');
  }

  Future<void> save() async {
    await Api().write(url: '/meta/pred.json', data: data);
  }

  void init(String code) {
    if (data[code] != null) return;
    data[code] = {
      "data": [0, 0],
      'queue': [0, 0]
    };
  }

  int findQueue({required String code, bool up = true}) {
    if (up) {
      return data[code]?['queue']?[0] ?? 0;
    } else {
      return data[code]?['queue']?[1] ?? 0;
    }
  }

  int findData({required String code, bool up = true}) {
    if (up) {
      return data[code]?['data']?[0] ?? 0;
    } else {
      return data[code]?['data']?[1] ?? 0;
    }
  }

  Future<void> add({required String code, bool up = true}) async {
    await load();
    init(code);
    if (up) {
      data[code]?['queue']?[0]++;
    } else {
      data[code]?['queue']?[1]++;
    }
    await save();
  }

  @override
  String toString() {
    return data.toString();
  }
}

class PredDataItem {
  PredQueueItem queue;
  int toPrice;
  DateTime? scored;

  DateTime? get predicted => queue.predicted;
  bool get up => queue.up;
  String get uid => queue.uid;
  String get code => queue.code;
  int get fromPrice => queue.fromPrice;
  // -1 틀림 0 보합 1 맞음
  int get ox =>
      (fromPrice == toPrice ? 0 : (up == fromPrice > toPrice ? 1 : -1));

  PredDataItem({
    required this.queue,
    this.toPrice = 0,
    this.scored,
  });

  factory PredDataItem.fromJson(json) {
    return PredDataItem(
      queue: PredQueueItem.fromJson(json),
      toPrice: json['s'],
      scored: DateTime.fromMillisecondsSinceEpoch(json['scored']),
    );
  }

  Map toJson() {
    return {
      ...queue.toJson(),
      "s": toPrice,
      "p": ox,
      "scored": scored?.ms,
    };
  }
}

class PredQueueItem {
  DateTime? predicted;
  bool up;

  String uid, code;
  int fromPrice;

  PredQueueItem({
    this.predicted,
    this.uid = '',
    this.code = '',
    this.up = true,
    this.fromPrice = 0,
  });

  // tojson, fromjson 만들기
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'code': code,
      'o': fromPrice,
      'd': predicted?.millisecondsSinceEpoch,
      'od': up ? 1 : -1,
    };
  }

  factory PredQueueItem.fromJson(json) {
    return PredQueueItem(
      uid: json['uid'].toString(),
      code: json['code'].toString(),
      up: json['od'] == 1,
      fromPrice: json['o'],
      predicted: DateTime.fromMillisecondsSinceEpoch(json['d']),
    );
  }
}
