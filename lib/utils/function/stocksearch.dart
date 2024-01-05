import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/priceview.dart';

class SearchResultDialog extends StatefulWidget {
  final Function(String) onPressItem;

  const SearchResultDialog({super.key, required this.onPressItem});

  @override
  State<SearchResultDialog> createState() => _SearchResultDialogState();
}

class _SearchResultDialogState extends State<SearchResultDialog> {
  List<StockData> _result = [];
  final codeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.primary.darken(.1),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              cursorColor: theme.colorScheme.onPrimary,
              style: theme.textTheme.labelLarge,
              controller: codeController,
              onChanged: (v) {
                if (v.isEmpty) return;
                setState(() {
                  _result = Stock().filter(v);
                });
              },
              onSubmitted: (v) {
                if (_result.isNotEmpty) {
                  widget.onPressItem(_result.first.code);
                }
              },
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
                hintText: '종목 코드 / 종목명',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(
                    r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]')),
              ],
            ),
            Container(
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._result.map(
                      (e) => TextButton(
                        onPressed: () {
                          widget.onPressItem(e.code);
                          router.pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name,
                                      style: theme.textTheme.bodyLarge),
                                  Text(e.code,
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                PriceView(
                                  e.lastPrice,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Row(
                                  children: [
                                    PriceColorView(
                                      e.priceChange,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    SizedBox(width: 3),
                                    PriceColorView(
                                      e.priceChangeRatio,
                                      style: theme.textTheme.bodySmall,
                                      asPercent: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
