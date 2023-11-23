import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:http/http.dart' as http;

class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  stock(Stock stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xffFFFFFF),
                ),
              ),
              Text(
                stock.code!,
                style: const TextStyle(
                  color: Color(0xffFFFFFF),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.currentPrice!.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xffFFFFFF),
                ),
              ),
              Row(children: [
                Text(
                  stock.priceChangeRatio! > 0
                      ? '+${stock.priceChangeRatio!.toStringAsFixed(2)}%'
                      : '${stock.priceChangeRatio!.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color:
                        stock.priceChangeRatio! > 0 ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  stock.priceChange! > 0
                      ? '+${stock.priceChange!}'
                      : '${stock.priceChange!}',
                  style: TextStyle(
                    color: stock.priceChange! > 0 ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  data() {
    return Container(
      child: LoginUser().valid
          ? Column(
              children: List<Widget>.from(
              LoginUser().user.favs!.map(
                    (e) => stock(e),
                  ),
            ))
          : Column(
              children: List<Widget>.from([
                stock(Stock.fromCode('005930')),
                stock(Stock.fromCode('000660')),
              ]),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: data(),
      ),
    );
  }
}
