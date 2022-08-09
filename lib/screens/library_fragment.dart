import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/my_book_screen.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/services/db_services.dart' as services;
import 'package:soma/utils/helpers/screen_navigation.dart';

class LibraryFragment extends StatefulWidget {
  LibraryFragment({Key key}) : super(key: key);

  @override
  _LibraryFragmentState createState() => _LibraryFragmentState();
}

class _LibraryFragmentState extends State<LibraryFragment> {

  Future<QuerySnapshot> _getMyBooks() {
    return services.getBooksOf("publisherId");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _getMyBooks(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Text("My books", style: ProfileTextStyle.header,),
                        ),
                        SizedBox(height: 10,),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: snapshot.data.docs.map((e) => InkWell(
                              onTap: () => ScreenNavigation.navigate(context, MyBookScreen(e.id, author: e["author"], title: e["title"],)),
                              child: Container(
                                height: 200,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                width: 120,
                                child: Image.network(
                                    e["artwork"] != "" ? e["artwork"] : null,
                                    fit: BoxFit.cover
                                ),
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            )).toList(),
                          ),
                        ),
                        SizedBox(height: 30,),
                      ],
                    );
                  } else {
                    return Text("");
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text("Library", style: ProfileTextStyle.header,),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}