import 'package:flutter/material.dart';

class InputScreen extends StatefulWidget {
  InputScreen({Key key, this.title = "", this.inputHint = "", this.value = ""}) : super(key: key);

  final String title;
  final String inputHint;
  String value;

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.trim() == "" ? "" : widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Divider(height: 1,),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: widget.inputHint,
                border: InputBorder.none,
              ),
            ),
            Divider(height: 1,),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, _controller.text),
                child: Text("Ok"),
              ),
            ),
            Divider(height: 1,),
          ],
        ),
      ),
    );
  }
}