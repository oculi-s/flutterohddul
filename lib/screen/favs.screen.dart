import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/prediction.dart';

import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/base/vars.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/function/shouldlogin.dart';
import 'package:flutterohddul/utils/function/stocksearch.dart';
import 'package:flutterohddul/utils/priceview.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/data/user.dart';

import 'package:flutterohddul/external/stockslide.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List defaultList = [];
  List list = [];

  @override
  void initState() {
    defaultList = List.from(
      defaultFavs.map(
        (e) => Stock().hasCode(e) ? Stock().fromCode(e) : e,
      ),
    );
    list = Log().loggedin ? Log().user!.favs : defaultList;

    super.initState();
  }

  _onlogin() {
    if (Log().loggedin) {
      list = Log().user!.favs;
      setState(() {});
    }
  }

  _snackBar(i, e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          "삭제완료",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        action: SnackBarAction(
          textColor: Theme.of(context).colorScheme.onPrimary,
          label: '실행취소',
          onPressed: () {
            setState(() {
              list.insert(i, e);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Section(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(''),
              IconButton(
                  onPressed: () {
                    if (shouldLoginDialog(context)) return;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SearchResultDialog(onPressItem: (e) {
                          list.add(e);
                          setState(() {});
                        });
                      },
                    );
                  },
                  icon: Icon(Icons.add)),
            ],
          ),
        ),
        Section(
          child: Column(
            children: list
                .mapIndexed((i, e) => ([
                      DragDestination(
                        onAccept: (int from) {
                          int to = i;
                          if (from < to) to--;
                          if (from == to) return;
                          setState(() {
                            var c = list[from];
                            list.removeAt(from);
                            list.insert(to, c);
                            Api().fav(data: list.stockOrString());
                          });
                        },
                      ),
                      e is StockData
                          ? StockBlock(
                              stock: e,
                              i: i,
                              onDelete: () {
                                if (shouldLoginDialog(context, _onlogin)) {
                                  setState(() {});
                                  return;
                                }
                                setState(() {
                                  list.removeAt(i);
                                  _snackBar(i, e);
                                  Api().fav(data: list.stockOrString());
                                });
                              },
                              onLogin: _onlogin,
                            )
                          : TextBlock(
                              text: e,
                              i: i,
                              editText: (v) {
                                if (shouldLoginDialog(context, _onlogin)) {
                                  return;
                                }
                                setState(() {
                                  list[i] = v;
                                  Api().fav(data: list.stockOrString());
                                });
                              },
                              onLogin: _onlogin,
                            ),
                    ]))
                .flatten(),
          ),
        ),
      ],
    );
  }
}

class DragDestination extends StatefulWidget {
  Function onAccept;

  DragDestination({
    super.key,
    required this.onAccept,
  });

  @override
  State<DragDestination> createState() => _DragDestinationState();
}

class _DragDestinationState extends State<DragDestination> {
  bool _willAccept = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _willAccept ? 20 : 3,
      decoration: BoxDecoration(color: Theme.of(context).dividerColor),
      child: DragTarget(
        builder: (context, data, rejects) {
          return Container();
        },
        onMove: (details) {
          setState(() {
            _willAccept = true;
          });
        },
        onLeave: (data) {
          setState(() {
            _willAccept = false;
          });
        },
        onAccept: (int from) {
          widget.onAccept(from);
          setState(() {
            _willAccept = false;
          });
        },
      ),
    );
  }
}

class StockBlock extends StatefulWidget {
  final StockData stock;
  final Function onDelete, onLogin;
  final int i;

  const StockBlock({
    super.key,
    required this.stock,
    required this.onDelete,
    required this.onLogin,
    required this.i,
  });

  @override
  State<StockBlock> createState() => _StockBlockState();
}

class _StockBlockState extends State<StockBlock> {
  late bool _selected;
  late bool _predictable;

  @override
  initState() {
    super.initState();
    _selected = false;
    _predictable = true;
  }

  _child([bool _isfeedback = false]) {
    var theme = Theme.of(context);
    return Opacity(
      opacity: _isfeedback ? 0.7 : 1,
      child: Slidable(
        key: UniqueKey(),
        enabled: !_isfeedback,
        startActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: .3,
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (e) async {
                if (shouldLoginDialog(context)) return;
                if (!_predictable) return;
                Pred().add(context, widget.stock, true);
                _predictable = false;
              },
              icon: Icons.thumb_up,
              label: '오',
              padding: EdgeInsets.zero,
              backgroundColor: Theme.of(context).colorScheme.bull.darken(.1),
            ),
            SlidableAction(
              onPressed: (e) async {
                if (shouldLoginDialog(context)) return;
                if (!_predictable) return;
                Pred().add(context, widget.stock, false);
                _predictable = false;
              },
              icon: Icons.thumb_down,
              label: '떨',
              padding: EdgeInsets.zero,
              backgroundColor: Theme.of(context).colorScheme.bear,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: .2,
          closeThreshold: .99,
          dragDismissible: true,
          dismissible: DismissiblePane(
            onDismissed: () {
              widget.onDelete();
            },
          ),
          children: [
            SlidableAction(
              onPressed: (e) {
                widget.onDelete();
              },
              icon: Icons.delete,
              label: '삭제',
              backgroundColor: Theme.of(context).colorScheme.bear.darken(.2),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: _selected
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
          ),
          width: Screen(context).w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 35,
                height: 35,
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                child: widget.stock.img,
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stock.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          widget.stock.code,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PriceView(
                          widget.stock.currentPrice,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Row(children: [
                          PriceColorView(
                            widget.stock.priceChange,
                            asPercent: false,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 10),
                          PriceColorView(
                            widget.stock.priceChangeRatio,
                            asPercent: true,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StockSlide(stock: widget.stock);
          },
        );
      },
      child: LongPressDraggable(
        axis: Axis.vertical,
        data: widget.i,
        child: _child(),
        feedback: _child(true),
        onDragStarted: () {
          if (shouldLoginDialog(context, widget.onLogin)) return;
          setState(() {
            _selected = true;
          });
        },
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            _selected = false;
          });
        },
        onDragEnd: (e) {
          setState(() {
            _selected = false;
          });
        },
      ),
    );
  }
}

class TextBlock extends StatefulWidget {
  final String text;
  final Function editText, onLogin;
  final int i;

  const TextBlock({
    super.key,
    required this.text,
    required this.editText,
    required this.onLogin,
    required this.i,
  });

  @override
  State<TextBlock> createState() => _TextBlockState();
}

class _TextBlockState extends State<TextBlock> {
  bool _selected = false;
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    _child([bool _isfeedback = false]) {
      return Opacity(
        opacity: _isfeedback ? 0.7 : 1,
        child: Container(
            height: 30,
            width: Screen(context).w,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: _isfeedback
                    ? theme.colorScheme.primary
                    : _selected
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: theme.textTheme.bodyMedium,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  hoverColor: Colors.transparent,
                  onPressed: () {
                    if (shouldLoginDialog(context, widget.onLogin)) return;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: theme.colorScheme.primary,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            height: 200,
                            child: Column(
                              children: [
                                TextField(
                                  autofocus: true,
                                  controller: _editingController,
                                  onSubmitted: (v) {
                                    widget.editText(v);
                                    router.pop();
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        router.pop();
                                      },
                                      child: Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget
                                            .editText(_editingController.text);
                                        router.pop();
                                      },
                                      child: Text('확인'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.edit, size: 14),
                )
              ],
            )),
      );
    }

    return LongPressDraggable(
      axis: Axis.vertical,
      data: widget.i,
      feedback: _child(true),
      child: _child(),
      onDragStarted: () {
        if (shouldLoginDialog(context, widget.onLogin)) return;
        setState(() {
          _selected = true;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _selected = false;
        });
      },
      onDragEnd: (e) {
        setState(() {
          _selected = false;
        });
      },
    );
  }
}
