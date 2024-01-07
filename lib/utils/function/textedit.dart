import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/utils/base/base.dart';

class TextEditingDialog extends StatefulWidget {
  final Function editText;
  final String? text;

  const TextEditingDialog({
    super.key,
    required this.editText,
    this.text,
  });

  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.onPrimaryContainer,
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
                const SizedBox(width: 10),
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
  }
}
