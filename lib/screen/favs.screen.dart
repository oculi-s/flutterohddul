import 'package:flutter/material.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/user.dart';

class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  stock(Stock stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              stock.currentPrice!.toStringAsFixed(2),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Change',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              stock.priceChange! > 0
                  ? '+${stock.priceChange!.toStringAsFixed(2)}'
                  : stock.priceChange!.toStringAsFixed(2),
              style: TextStyle(
                color: stock.priceChange! > 0 ? Colors.green : Colors.red,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  data() {
    return LoginUser().user.valid
        ? Column(
            children: List<Widget>.from(
            LoginUser().user.favs!.map(
                  (e) => stock(e),
                ),
          ))
        : const Column();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data(),
    );
  }
}
