import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soma/screens/chapters_screen.dart';
import 'package:soma/screens/reoder_list_screen.dart';
import 'package:soma/utils/helpers/screen_navigation.dart';
import 'package:soma/utils/services/db_services.dart' as services;
import 'package:soma/utils/helpers/helpers.dart' as helpers;
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/services/book.services.dart';
import 'dart:math';

import 'input_screen.dart';

class _ShimmerWidget extends StatelessWidget {

  Color baseColor = Color.fromRGBO(190, 190, 190, 1);
  Color highlightColor = Color.fromRGBO(210, 210, 210, 1);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            color: Colors.grey,
            alignment: Alignment.center,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 320,
                width: 200,
                color: baseColor,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ListView.builder(
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, i) {
                return Container(
                  height: 15,
                  width: i == 5 ? 60 : double.infinity,
                  color: baseColor,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                );
              },
            ),
          ),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Container(
                  height: 15,
                  width: 120,
                  color: baseColor,
                  margin: EdgeInsets.only(left: 15),
                ),
                Container(
                  height: 15,
                  width: 180,
                  color: baseColor,
                  margin: EdgeInsets.only(left: 15, top: 10),
                ),
                Container(
                  height: 15,
                  width: 170,
                  color: baseColor,
                  margin: EdgeInsets.only(left: 15, top: 10),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyBookScreen extends StatefulWidget {
  MyBookScreen(this.bookId, {Key key, this.author = "", this.title = ""}) : super(key: key);

  final String bookId;
  final String author;
  final String title;

  @override
  _MyBookScreenState createState() => _MyBookScreenState();
}

class _MyBookScreenState extends State<MyBookScreen> {

  Book book;

  @override
  initState() {
    super.initState();
    book = Book(widget.bookId, context: context);
  }

  Widget _buttonGroup(snapshot) {
    Map<int, String> list = {};
    for (int i = 0; i < snapshot.data['chapters'].length; i++) {
      list.addAll({i: snapshot.data['chapters'][i]['name']});
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
              icon: Icon(Icons.add_outlined),
              onPressed: () => {
              ScreenNavigation.navigate(context, InputScreen(
              title: "${snapshot.data["title"]} - Add chapter",
              inputHint: "Chapter name",
              )).then((value) => _addChapter(value))
            }
          ),
          IconButton(
              icon: Icon(Icons.reorder),
              onPressed: () => ScreenNavigation.navigate(context, ReorderListScreen(
                title: '${widget.title} - Chapters edit',
                list: snapshot.data["chapters"],
              )).then((value) => _reorderChapters(value))
          ),
          SizedBox(width: 15,)
        ]
    );
  }

  Future<DocumentSnapshot> _getBook() {
    return services.getBookWithId(widget.bookId);
  }

  void _reorderChapters(list) async {
    if (list != null && list is List) {
      helpers.loadingScreen(
        context: context,
        message: 'Working...',
        persistent: true
      );
      await book.reorderChapters(list);
      Navigator.pop(context);
      setState(() {});
    }
  }

  void _addChapter(dynamic value) async {
    if (value != null) {
      if (value is String && value.trim() != "") {
        helpers.loadingScreen(
          context: context,
          message: "Adding chapter...",
          persistent: true
        );
        //await services.addChapterToBook(widget.bookId, value);
        await book.addChapter(value);
        Navigator.pop(context);
        setState(() { });
      }
    }
  }

  void _editChapter(int chapterIndex, dynamic value, String currentValue) async {
    Navigator.pop(context);
    if (value != null) {
      if (value is String && value.trim() != "" && value != currentValue) {
        helpers.loadingScreen(
          context: context,
          message: "Editing chapter...",
          persistent: true
        );
        await book.getChapter(chapterIndex).renameChapter(value);
        Navigator.pop(context);
        setState(() { });
      }
    }
  }

  void _showBottomSheet(int chapterIndex, String chapterName, int chapterCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => {},
                    title: Text("Publish", textAlign: TextAlign.center,),
                  ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => {
                      ScreenNavigation.navigate(context, InputScreen(
                        title: "$chapterName - Edit chapter",
                        inputHint: "Chapter name",
                        value: chapterName,
                      )).then((value) => _editChapter(chapterIndex, value, chapterName))
                    },
                    title: Text("Edit", textAlign: TextAlign.center,),
                  ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => {},
                    title: Text("Delete", textAlign: TextAlign.center, style: TextStyle(
                      color: Colors.red
                    ),),
                  )
                ],
              ),
            ),
            Container(
              height: 45,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                borderRadius: BorderRadius.circular(8)
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: Theme.of(context).textTheme.subtitle1),
                ),
              ),
            )
          ],
        );
      }
    );

  }

  @override
  Widget build(BuildContext context) {
    List list;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.author} - ${widget.title}"),
      ),
      body: FutureBuilder(
        future: _getBook(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 320,
                      color: Colors.black54,
                      child: snapshot.data["artwork"] != "" ? Image.network(
                        snapshot.data["artwork"],
                        fit: BoxFit.cover,
                      ) : Text(snapshot.data["title"]),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Text(snapshot.data["title"], style: ProfileTextStyle.header),
                          ),
                          SizedBox(height: 30,),
                          Text(snapshot.data["description"],
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 20,),
                          Text("Author : ${snapshot.data["author"]}"),
                          SizedBox(height: 5,),
                          Text("Year : ${snapshot.data["date"]}"),
                          SizedBox(height: 5,),
                          Text("Category : ${snapshot.data["categories"].join(', ')}"),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text("Chapters", style: ProfileTextStyle.header,),
                    ),
                    _buttonGroup(snapshot),
                    Column(
                      children: [
                        Divider(height: 1,),
                        ListView.separated(
                          shrinkWrap: true,
                          controller: ScrollController(keepScrollOffset: true),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data["chapters"].length,
                          separatorBuilder: (context, index) {
                            return Divider(height: 1,);
                            },
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () => ScreenNavigation.navigate(context, ChaptersScreen(
                                bookId: widget.bookId,
                                title: snapshot.data["title"],
                                chapterName: snapshot.data["chapters"][index]["name"],
                                chapterIndex: index,
                              )),
                              title: Text(snapshot.data["chapters"][index]["name"]),
                              trailing: IconButton(
                                onPressed: () => _showBottomSheet(index, snapshot.data["chapters"][index]["name"], snapshot.data["chapters"].length),
                                icon: Icon(Icons.more_vert),
                              ),
                              leading: snapshot.data["chapters"][index]["public"] ? null : Icon(Icons.public_off),
                            );
                            },
                        ),
                        Divider(height: 1,),
                      ],
                    ),
                    SizedBox(height: 40,),
                    Divider(height: 1,),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => {},
                        child: Text("Publish"),
                      ),
                    ),
                    Divider(height: 1,),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => {},
                        child: Text("Edit"),
                      ),
                    ),
                    Divider(height: 1,),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => {},
                        child: Text("Delete book", style: TextStyle(
                          color: Colors.red
                        ),),
                      ),
                    ),
                    Divider(height: 1,),
                    SizedBox(height: 40,),
                  ],
                ),
              );
            } else {
              return Text("An occurred error!");
            }
          }
          return _ShimmerWidget();
        },
      ),
    );
  }
}