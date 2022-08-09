import 'package:flutter/material.dart';

class ToggleChip extends StatefulWidget {
  ToggleChip({
    Key key,
    this.child,
    this.selected = false,
  }) : super(key: key);

  Widget child;
  bool selected;

  @override
  _ToggleChipState createState() => _ToggleChipState();
}

class _ToggleChipState extends State<ToggleChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10, bottom: 10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: widget.selected ? Theme.of(context).primaryColor : Colors.transparent,
          border: Border.all(
              color: widget.selected ? Colors.transparent : Colors.grey,
              style: BorderStyle.solid,
              width: 2
          ),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: widget.child,
      ),
    );
  }
}