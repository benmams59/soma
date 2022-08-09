import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/helpers/helpers.dart' as helpers;
import 'package:soma/utils/services/db_services.dart' as services;

class AddBookScreen extends StatefulWidget {
  AddBookScreen({Key key}) : super(key: key);

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  TextEditingController _titleController;
  TextEditingController _authorController;
  TextEditingController _tagsController;
  TextEditingController _descriptionController;
  TextEditingController _editionController;
  TextEditingController _dateController;
  TextEditingController _paperController;
  TextEditingController _othersController;

  bool _moreInformation = false;
  DateTime _onsetDate;
  List<String> _categories = [];
  Uint8List _image;
  
  List<int> _error = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _tagsController = TextEditingController();
     _descriptionController = TextEditingController();
     _editionController = TextEditingController();
    _dateController = TextEditingController();
    _paperController = TextEditingController();
    _othersController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    _editionController.dispose();
    _dateController.dispose();
    _paperController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
              children: [
                Container(
                  height: (MediaQuery.of(context).size.height - 120) / 2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomAppBarColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: StatefulBuilder(
                    builder: (context, setStateBuilder) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15, bottom: 10),
                              child: Text("Fiction", style: ProfileTextStyle.header,),
                            ),
                            ListView.separated(
                              controller: ScrollController(keepScrollOffset: true),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: helpers.categories["fiction"].length,
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                );
                              },
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    setStateBuilder(() {
                                      if (_categories.contains(helpers.categories["fiction"][index])) {
                                        _categories.remove(helpers.categories["fiction"][index]);
                                      } else {
                                        _categories.add(helpers.categories["fiction"][index]);
                                      }
                                    });
                                    ///setState(() {});
                                  },
                                  title: Text(helpers.categories["fiction"][index]),
                                  trailing: _categories.contains(helpers.categories["fiction"][index]) ? Icon(Icons.check_outlined) : null,
                                );
                              },
                            ),
                            Divider(height: 1,),
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15, bottom: 10),
                              child: Text("Non-Fiction", style: ProfileTextStyle.header,),
                            ),
                            ListView.separated(
                              controller: ScrollController(keepScrollOffset: true),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: helpers.categories["non-fiction"].length,
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                );
                              },
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    setStateBuilder(() {
                                      if (_categories.contains(helpers.categories["non-fiction"][index])) {
                                        _categories.remove(helpers.categories["non-fiction"][index]);
                                      } else {
                                        _categories.add(helpers.categories["non-fiction"][index]);
                                      }
                                    });
                                    ///setState(() {});
                                  },
                                  title: Text(helpers.categories["non-fiction"][index]),
                                  trailing: _categories.contains(helpers.categories["non-fiction"][index]) ? Icon(Icons.check_outlined) : null,
                                );
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 5,),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).bottomAppBarColor,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ),
                )
              ],
            ),
        );
      }
    ).then((value) => setState(() => _error.remove(2)));
  }

  void _pickImage() async {
    File file = await helpers.pickImage();
    if (file != null) _image = await helpers.compressFile(file);
    setState(() { });
  }

  Future<void> _submit() async {
    _error.clear();
    if (_titleController.text.trim().isEmpty)
      _error.add(0);
    if (_authorController.text.trim().isEmpty)
      _error.add(1);
    if (_categories.length == 0)
      _error.add(2);
    if (_tagsController.text.trim().isEmpty && !_tagsController.text.contains('#'))
      _error.add(3);

    if(_error.isNotEmpty) {
      setState(() { });
      return;
    }

   if ( FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser.isAnonymous) {
     Map<String, dynamic> data = helpers.Book(
       _titleController.text,
       _authorController.text,
       _categories,
       _tagsController.text,
       artwork: _image,
       publisher: FirebaseAuth.instance.currentUser.displayName,
       publisherId: FirebaseAuth.instance.currentUser.uid,
       publicationDate: Timestamp.now(),
       description: _descriptionController.text,
       edition: _editionController.text,
       date: int.parse(_dateController.text),
       paper: _paperController.text,
       others: _othersController.text
     ).toMap();
     helpers.loadingScreen(
       context: context,
       message: "Creating...",
       persistent: true
     );
     try {
       await services.addBook(data);
       Navigator.pop(context);
     } catch(e) {
       print(e);
     }
     Navigator.pop(context);
   }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add book"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cover", style: ProfileTextStyle.header,),
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          InkWell(
                            onTap: _image == null ? () => _pickImage() : null,
                            child: Container(
                              height: 240,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 240,
                            child: _image == null ? Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.grey,
                            )
                            :
                            Image.memory(
                              _image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_image != null)
                          Container(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _image = null),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0
                              ),
                              icon: Icon(Icons.delete_outlined),
                              label: Text("Delete cover"),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                  ],
                ),
              ),
              CustomListView(
                title: "Information",
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: (change) => setState(() => _error.remove(0)),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: "Title",
                        errorText: _error.contains(0) ? "Can't be empty" : null,
                        border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  TextField(
                    onChanged: (change) => setState(() => _error.remove(1)),
                    controller: _authorController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Author",
                      errorText: _error.contains(1) ? "Can't be empty" : null,
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            child: _categories.length > 0 ? Row(
                              children: _categories.map((e) => Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Chip(
                                  label: Text(e),
                                  onDeleted: () => setState(() => _categories.remove(e)),
                                  deleteIcon: Icon(
                                    Icons.close_outlined,
                                    size: 18,
                                  ),
                                ),
                              )).toList(),
                            ) : Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text("Category", style: TextStyle(
                                  color: _error.contains(2) ? Colors.red : Theme.of(context).hintColor,
                                  fontSize: 16
                              ),),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white10,
                        child: IconButton(
                          onPressed: () => _showCategorySelection(),
                          icon: Icon(Icons.add_outlined),
                        ),
                      )
                    ],
                  ),
                  Divider(height: 1,),
                  TextField(
                    controller: _tagsController,
                    onChanged: (change) => setState(() => _error.remove(3)),
                    maxLines: 3,
                    maxLength: 200,
                    buildCounter: (context, {int currentLength, bool isFocused, int maxLength}) {
                      return isFocused ? Text("$currentLength/$maxLength", style: TextStyle(
                          color: Colors.grey
                      ),) : null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      hintText: "Tags",
                      helperText: "ex: #frantz#fanon#essay",
                      errorText: _error.contains(3) ? "Can't be empty" : null,
                      helperStyle: TextStyle(
                        fontStyle: FontStyle.italic
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 1500,
                    buildCounter: (context, {int currentLength, bool isFocused, int maxLength}) {
                      return isFocused ? Text("$currentLength/$maxLength", style: TextStyle(
                          color: Colors.grey
                      ),) : null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      hintText: "Description",
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                ],
              ),
              SizedBox(height: 30,),
              if (_moreInformation)
              CustomListView(
                title: "More information",
                children: [
                  TextField(
                    controller: _editionController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Edition",
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  TextField(
                    controller: _dateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Year",
                      helperText: "ex: 2019",
                      helperStyle: TextStyle(
                        fontStyle: FontStyle.italic
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  TextField(
                    controller: _paperController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Paper version (site)",
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                  TextField(
                    controller: _othersController,
                    maxLines: 6,
                    maxLength: 500,
                    buildCounter: (context, {int currentLength, bool isFocused, int maxLength}) {
                      return isFocused ? Text("$currentLength/$maxLength", style: TextStyle(
                          color: Colors.grey
                      ),) : null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      hintText: "Others information",
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(height: 1,),
                ],
              ),
              CheckboxListTile(
                title: Text("Edit more information"),
                value: _moreInformation,
                onChanged: (value) => setState(() => _moreInformation = value),
              ),
              SizedBox(height: 30,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 0.1
                    )
                  ]
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _submit(),
                    child: Text("Create"),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15)
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}