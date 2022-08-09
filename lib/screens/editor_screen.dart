import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:zefyr/zefyr.dart";
import "package:quill_delta/quill_delta.dart";
import "package:soma/utils/services/db_services.dart" as services;
import 'package:soma/utils/helpers/helpers.dart' as helpers;

class EditorScreen extends StatefulWidget {
  EditorScreen({Key key, this.source, this.bookId, this.chapterIndex, this.chapterName = "", this.pageIndex, this.pageTitle = ""}) : super(key: key);

  final String source;
  final String bookId;
  final int chapterIndex;
  final String chapterName;
  final int pageIndex;
  final String pageTitle;

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  ZefyrController _controller;
  TextSelectionControls controls;
  FocusNode _focusNode;

  @override
  initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  Future<NotusDocument> _getDocument() async {
    if (_controller == null) {
      NotusDocument doc = await services.loadPage(
          widget.bookId, widget.chapterIndex, widget.pageIndex);
      return doc;
    } else return _controller.document;
  }

  void _saveDocument() async {
    Delta delta = _controller.document.toDelta();
    FocusScope.of(context).unfocus();
    helpers.loadingScreen(
      context: context,
      message: "Saving...",
      persistent: false
    );
    await services.savePage(delta, widget.bookId, widget.chapterIndex, widget.pageIndex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          alignment: Alignment.bottomRight,
          height: 80,
          child: Row(
            children: [
              SizedBox(width: 15,),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_outlined),
              ),
              Flexible(child: Text("${widget.chapterName} - ${widget.pageTitle}", style: TextStyle(
                  fontSize: 18
              ), overflow: TextOverflow.ellipsis,), flex: 1,),
              Spacer(flex: 2,),
              IconButton(
                onPressed: () => _saveDocument(),
                icon: Icon(Icons.check_outlined),
              ),
              SizedBox(width: 15,),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getDocument(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (_controller == null) {
              _controller = ZefyrController(
                 snapshot.data
              );
            }
            return ZefyrTheme(
              data: ZefyrThemeData(
              ),
              child: ZefyrScaffold(
                child: ZefyrEditor(
                  controller: _controller,
                  focusNode: _focusNode,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("An error occurred"),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}