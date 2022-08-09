import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

final Map<String, List<String>> categories = {
  "fiction" : [
    "Action and Adventure",
    "Anthology",
    "Classic",
    "Comic and Graphic novel",
    "Crime and Detective",
    "Drama",
    "Fable",
    "Fairy Tale",
    "Fantasy",
    "Historical Fiction",
    "Horror",
    "Humor",
    "Legend",
    "Magical realism",
    "Mystery",
    "Mythology",
    "Realistic Fiction",
    "Romance",
    "Satire",
    "Science Fiction (Sci-Fi)",
    "Short story",
    "Suspense / Thriller"
  ],
  "non-fiction" : [
    "Biography / Autobiography",
    "Essay",
    "Memoir",
    "Narrative nonfiction",
    "Periodicals",
    "Reference books",
    "Self-help book",
    "Speech",
    "Textbook",
    "Poetry"
  ]
};

void loadingScreen({
  BuildContext context,
  String message = "",
  bool persistent = false,
}) {
  showDialog(
    barrierDismissible: !persistent,
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(message, style:
                Theme.of(context).textTheme.subtitle1,),
              ),
              SizedBox(height: 20, width: double.infinity,),
              Container(
                child: Platform.isIOS ?
                CupertinoActivityIndicator()
                    :
                CircularProgressIndicator(),
              ),
              SizedBox(height: 20, width: double.infinity,),
            ],
          ),
        ),
      );
    }
  );
}

bool emailRegex(String email) {
  return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(email);
}

bool passwordRegex(String password) {
  return RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$").hasMatch(password);
}

Future<File> pickImage() async {
  final picker =  ImagePicker();
  var pickedFile;
  try {
    pickedFile = await picker.getImage(source: ImageSource.gallery);
  } catch (e) {
    print(e);
  }

  if (pickedFile != null)
    return File(pickedFile.path);
  else return null;
}

Future<Uint8List> compressFile(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minHeight: 500,
    minWidth: 500,
    quality: 90,
    format: CompressFormat.jpeg
  );
  return result;
}

class Book {
  Book(
      this.title,
      this.author,
      this.categories,
      this.tags,
      {
        this.artwork,
        this.description,
        this.edition,
        this.date,
        this.paper,
        this.others,
        this.publisherId,
        this.publicationDate,
        this.publisher,
      }
      );

  final String title;
  final String author;
  final List<String> categories;
  final String tags;
  final Uint8List artwork;
  final String description;
  final String edition;
  final int date;
  final String paper;
  final String others;

  final String publisher;
  final String publisherId;
  final Timestamp publicationDate;

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "author": author,
      'categories': categories,
      "tags": tags,
      "artwork": artwork,
      "description": description,
      "edition": edition,
      "date": date,
      "paper": paper,
      "others": others,
      "publisher": publisher,
      "publisherId": publisherId,
      "publicationDate": publicationDate,
      "chapters": [],
      "comments": 0,
      "rating": 0.0,
      "public": false
    };
  }
}