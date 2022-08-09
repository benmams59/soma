
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

class Book {
  Book(this.id, {
    this.collection = "books",
    this.context
  }) {
    // Default collection reference
    _collectionReference = FirebaseFirestore.instance.collection(collection);
  }

  final String collection; // The collection where queries will be running.
  final BuildContext context; // The parent widget context.

  final String id; // The book's ID in Firestore.

  CollectionReference _collectionReference;

  // Add book in Firestore database.
  // and return the book's ID.
  static Future<String> addBook() {}


  // Get data of book with query
  static Future<DocumentSnapshot> getDataOf(String field) {
  }

  // Get Firestore "Document" object
  DocumentReference _getDocument() {
    DocumentReference reference = _collectionReference.doc(id);
    return reference;
  }

  // Get book's data
  Future<DocumentSnapshot> getData() async {
    return _collectionReference.doc(id).get();
  }

  // Add a chapter inside current book.
  // and return the chapter's index in chapters array.
  Future<int> addChapter(String name) async {
    DocumentReference reference =  _getDocument();
    DocumentSnapshot snapshot = await reference.get();
    List<dynamic> chapters = snapshot['chapters'];
    for(int i = 0; i < chapters.length; i++) {
      if (chapters[i]['name'] == name)
        throw("Book already contains this chapter!");
    }
    chapters.add({
      'name': name,
      'public': false,
      'pages': []
    });
    reference.update({'chapters': chapters});

    return (chapters.length-1);
  }

  _Chapter getChapter(int index) {
    return _Chapter(this, index);
  }

  Future<void> reorderChapters(list) async {
    await _getDocument().update({
      "chapters": list
    });
  }
}

class _Chapter {
  _Chapter(this.book, this.index);

  final Book book;
  final int index;

  // Add Page to chapter
  Future<void> addPage(String name) async {
    DocumentSnapshot bookData = await book.getData();
    List<dynamic> chapters = bookData['chapters'];
    for (int i = 0; i < chapters[index]['pages'].length; i++) {
      if (chapters[index]['pages'][i]['name'] == name)
        throw("This chapter already contains this page");
    }
    chapters[index]['pages'].add({
      'name': name,
      'source': ''
    });
    await book._getDocument().update({
      'chapters': chapters
    });
  }

  Future<void> publishChapter() async {

  }

  Future<void> renameChapter(String name) async {
    DocumentSnapshot snapshot = await book.getData();
    List<dynamic> chapters = snapshot['chapters'];
    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i]['name'] == name)
        throw('A chapter have already get this name!');
    }
    chapters[index]['name'] = name;
    book._getDocument().update({'chapters': chapters});
  }

  // Get List of pages
  Future<List> getPages() async {
    DocumentSnapshot snapshot = await book.getData();
    return snapshot['chapters'][index]['chapters'];
  }

  _Page page(int pageIndex) {
    return _Page(book, book.id, index, pageIndex);
  }
}

class _Page {
  _Page(this.book, this.bookId, this.chapterIndex, this.index) {
    _collectionReference = book._getDocument().collection('pages');
  }
  Book book;
  final String bookId;
  final int chapterIndex;
  final index;

  CollectionReference _collectionReference;

  Future<void> savePage(Delta document) async {
    String documentString = json.encode(document.toJson());
    DocumentSnapshot snapshot = await book.getData();
    if (snapshot['chapters'][chapterIndex]['pages'][index]['source'].trim().isEmpty) {
      DocumentReference reference = await _collectionReference.add({
        'document': documentString
      });
      List<dynamic> chapters = snapshot['chapters'];
      chapters[chapterIndex]['pages'][index]['source'] = reference.id;
      reference.update({'chapters': chapters});
    } else
      await _collectionReference.doc(snapshot['chapters'][chapterIndex]['pages']['source']).update({
        'document': documentString
      });
  }

  Future<NotusDocument> loadPage() async {
    DocumentSnapshot snapshot = await book.getData();
    if (snapshot['chapters'][chapterIndex][index]['source'].trim().isEmpty) {
      Delta delta = Delta();
      delta.insert('\n');
      return NotusDocument.fromDelta(delta);
    } else {
      DocumentSnapshot pageDocument = await book._getDocument().collection('pages').doc(snapshot['chapters'][chapterIndex]['pages'][index]['source']).get();
      Delta delta = Delta();
      return NotusDocument.fromJson(json.decode(pageDocument['document']));
    }
  }
}