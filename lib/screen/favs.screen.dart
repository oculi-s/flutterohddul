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
  List widgets = [];
  bool _edit = false;

  @override
  void initState() {
    var favs = Log().loggedin ? Log().user!.favs : defaultFavs;
    widgets = favs.favsToWidget();
    super.initState();
  }

  _onlogin() {
    if (Log().loggedin) {
      setState(() {
        widgets = Log().user!.favs.favsToWidget();
      });
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
              widgets.insert(i, e);
            });
          },
        ),
      ),
    );
  }

  _getPredicted(stock) {
    if (!Log().loggedin) return 0;
    return Log().user!.predictionCode(stock.code);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Section(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  if (shouldLoginDialog(context, _onlogin)) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SearchResultDialog(onPressItem: (e) {
                        var s = Stock().hasCode(e) ? Stock().fromCode(e) : e;
                        if (widgets.contains(s)) return;
                        widgets.add(s);
                        Api().fav(data: widgets);
                        setState(() {});
                      });
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  if (shouldLoginDialog(context, _onlogin)) return;
                  setState(() {
                    _edit = !_edit;
                  });
                },
                icon: _edit ? Icon(Icons.check) : Icon(Icons.edit),
              )
            ],
          ),
        ),
        Section(
          child: SlidableAutoCloseBehavior(
            child: Column(
              children: widgets
                  .mapIndexed(
                    (i, e) => [
                      DragDestination(
                        onAccept: (int from) {
                          int to = i;
                          if (from < to) to--;
                          if (from == to) return;
                          setState(() {
                            var c = widgets[from];
                            widgets.removeAt(from);
                            widgets.insert(to, c);
                            Api().fav(data: widgets);
                          });
                        },
                      ),
                      e is StockData
                          ? StockBlock(
                              edit: _edit,
                              predicted: _getPredicted(e),
                              stock: e,
                              i: i,
                              onDelete: () {
                                if (shouldLoginDialog(context, _onlogin)) {
                                  return;
                                }
                                setState(() {
                                  widgets.removeAt(i);
                                  _snackBar(i, e);
                                  Api().fav(data: widgets);
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
                                  widgets[i] = v;
                                  Api().fav(data: widgets);
                                });
                              },
                              onLogin: _onlogin,
                            ),
                    ],
                  )
                  .flatten(),
            ),
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
  bool edit;
  int predicted;
  final int i;

  StockBlock({
    super.key,
    required this.stock,
    required this.onDelete,
    required this.onLogin,
    required this.predicted,
    required this.edit,
    required this.i,
  });

  @override
  State<StockBlock> createState() => _StockBlockState();
}

class _StockBlockState extends State<StockBlock> {
  late bool _selected;

  @override
  initState() {
    super.initState();
    _selected = false;
  }

  _child([bool _isfeedback = false]) {
    double colorfactor = widget.edit ? 0.02 : 0;
    var theme = Theme.of(context);
    return Opacity(
      opacity: _isfeedback ? 0.7 : 1,
      child: Dismissible(
        direction: widget.edit
            ? DismissDirection.endToStart
            : widget.predicted != 0
                ? DismissDirection.none
                : DismissDirection.horizontal,
        key: UniqueKey(),
        dismissThresholds: const {
          DismissDirection.endToStart: .8,
          DismissDirection.startToEnd: .8
        },
        resizeDuration: Duration.zero,
        confirmDismiss: widget.edit
            ? (d) async {
                if (shouldLoginDialog(context)) return false;
                widget.onDelete();
                return true;
              }
            : (d) async {
                if (shouldLoginDialog(context)) return false;
                if (d == DismissDirection.startToEnd) {
                  await Pred().add(context, widget.stock, true);
                  setState(() {
                    widget.predicted = 1;
                  });
                } else if (d == DismissDirection.endToStart) {
                  await Pred().add(context, widget.stock, false);
                  setState(() {
                    widget.predicted = -1;
                  });
                }
                return false;
              },
        background: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.colorScheme.bull.darken(.1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.thumb_up), Text('오')],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: theme.colorScheme.bear.darken(.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.edit
                ? [Icon(Icons.delete), Text('삭제')]
                : [Icon(Icons.thumb_down), Text('떨')],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.predicted == 0
                ? _selected
                    ? theme.colorScheme.secondary.lighten(colorfactor)
                    : theme.colorScheme.primary.lighten(colorfactor)
                : widget.predicted == 1
                    ? theme.colorScheme.bull.darken(.3 - colorfactor)
                    : theme.colorScheme.bear.darken(.4 - colorfactor),
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
          child: Text(
            widget.text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (shouldLoginDialog(context, widget.onLogin)) return;
        _editingController.text = widget.text;
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: theme.colorScheme.onPrimaryContainer,
              child: Container(
                padding: EdgeInsets.all(20.0),
                height: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      controller: _editingController,
                      onSubmitted: (v) {
                        widget.editText(v);
                        router.pop();
                      },
                      cursorColor: theme.colorScheme.onPrimary,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: theme.colorScheme.secondary,
                        filled: true,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RadiusButton(
                          context: context,
                          radius: 10,
                          backgroundColor: theme.colorScheme.secondary,
                          onPressed: () {
                            router.pop();
                          },
                          child: Text(
                            '취소',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        SizedBox(width: 10),
                        RadiusButton(
                          context: context,
                          radius: 10,
                          backgroundColor: theme.colorScheme.secondary,
                          onPressed: () {
                            widget.editText(_editingController.text);
                            router.pop();
                          },
                          child: Text(
                            '확인',
                            style: theme.textTheme.bodyLarge,
                          ),
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
      child: LongPressDraggable(
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
      ),
    );
  }
}
