import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/function/shouldlogin.dart';

class Pred {
  Pred._();
  static final Pred _instance = Pred._();
  factory Pred() => _instance;

  Map<String, List> count = {};

  Future<void> add(
    BuildContext context,
    StockData stock, [
    bool up = true,
  ]) async {
    // var uid = Log().user!.uid;
    // var pred = PredData(
    //   code: stock.code,
    //   fromPrice: stock.lastPrice,
    //   predicted: DateTime.now(),
    //   uid: uid,
    //   up: up,
    // );
    // count = await Api().read(url: '/meta/pred.json');
    // count[stock.code]?.first += 1;
    // var stockpred = await Api().read(url: '/stock/${stock.code}/pred.json');
    // var userpred = await Api().read(url: '/user/$uid/pred.json');
    // userpred['queue'].add(pred);
    // stockpred['data'].add(pred);
    // await Api().write(url: '/meta/pred.json', data: count);
    // await Api().write(url: '/stock/${stock.code}/pred.json', data: stockpred);
    // await Api().write(url: '/user/$uid/pred.json', data: userpred);
  }
}

class PredData {
  DateTime? predicted, scored;
  bool up;

  String uid, code;
  int fromPrice, toPrice;

  PredData({
    this.predicted,
    this.uid = '',
    this.code = '',
    this.up = true,
    this.fromPrice = 0,
    this.toPrice = 0,
  });

  // -1 틀림 0 보합 1 맞음
  int get ox => (fromPrice == toPrice
      ? 0
      : (up && fromPrice > toPrice || !up && fromPrice < toPrice ? 1 : -1));

  // tojson, fromjson 만들기
}
