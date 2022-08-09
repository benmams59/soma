import 'package:flutter/material.dart';
import 'package:soma/screens/editor_screen.dart';
import 'package:soma/screens/input_screen.dart';
import 'package:soma/utils/helpers/screen_navigation.dart';
import 'package:soma/utils/services/db_services.dart' as services;
import 'package:soma/utils/helpers/helpers.dart' as helpers;
import 'package:soma/utils/services/book.services.dart';

class ChaptersScreen extends StatefulWidget {
  ChaptersScreen({Key key, this.bookId, this.title = "", this.chapterIndex, this.chapterName = ""}) : super(key: key);

  final String title;
  final int chapterIndex;
  final String chapterName;
  final String bookId;

  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {

  Book book;

  @override
  void initState() {
    super.initState();
    book = Book(widget.bookId);
  }

  void _addPage(String title) async {
    helpers.loadingScreen(
      context: context,
      persistent: true,
      message: "Adding page..."
    );
    if (title != null && title.trim() != "") {
      /*await services.addPageToChapter(widget.bookId, widget.chapterIndex, title);
      setState(() {});*/
      await book.getChapter(widget.chapterIndex).addPage(title);
      setState(() {});
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    //Text("${widget.title} - ${widget.chapter}")
    return Scaffold(
      body: FutureBuilder(
        future: services.getChapterPages(widget.bookId, widget.chapterIndex),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> widgets = [];
            for (int i = 0; i < snapshot.data.length; i++) {
              widgets.add(ListTile(
                onTap: () => ScreenNavigation.navigate(context, EditorScreen(
                    source: "",
                  bookId: widget.bookId,
                  chapterIndex: widget.chapterIndex,
                  pageIndex: i,
                  chapterName: widget.chapterName,
                  pageTitle: snapshot.data[i]["name"],
                )),
                title: Text(snapshot.data[i]["name"]),
                trailing: Icon(Icons.navigate_next),
              ));
              if (i < snapshot.data.length-1)
                widgets.add(Divider(height: 1,));
            }
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("${widget.title} - ${widget.chapterName}", style: TextStyle(color: Colors.white),),
                  floating: true,
                  pinned: true,
                  snap: true,
                  expandedHeight: MediaQuery.of(context).size.height / 2,
                  backgroundColor: Colors.blueGrey,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        ListTile(
                          onTap: () => ScreenNavigation.navigate(context, InputScreen(
                            title: "${widget.chapterName} - New page",
                            inputHint: "Page title",)
                          ).then((value) => _addPage(value)),
                          title: Text("New page"),
                          leading: Icon(Icons.add_outlined),
                          trailing: IconButton(
                            icon: Icon(Icons.reorder),
                            onPressed: () => {},
                          ),
                        ),
                        Divider(height: 1,),
                        ...widgets.toList()
                      ]
                  ),
                )
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("An error occurred"),
                  SizedBox(height: 10,),
                  TextButton(
                    onPressed: () => setState(() => {}),
                    child: Text("Retry!"),
                  )
                ],
              ),
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