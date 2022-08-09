import 'package:flutter/material.dart';

class ReorderListScreen extends StatefulWidget {
  ReorderListScreen({
    Key key,
    this.title,
    this.list
  }) : super(key: key);

  final String title;
  final List<dynamic> list;

  _ReorderListScreenState createState() => _ReorderListScreenState();
}

class _ReorderListScreenState extends State<ReorderListScreen> {
  List<dynamic> _list;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context, _list),
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: Key('$index'),
            title: Text(_list[index]['name']),
            trailing: Icon(Icons.drag_handle),
          );
        },
        onReorder: (int i, int t) {
          setState(() {
            if (i < t) t -= 1;
            Map value = _list[i];
            _list.removeAt(i);
            _list.insert(t, value);
          });
        },
      ),
    );
  }
}