import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

Future<bool> fieldExist(String collection, String field, String value) async {
  QuerySnapshot query = await FirebaseFirestore.instance.collection(collection)
      .where(field, isEqualTo: value).get();
  return query.docs.length > 0;
}

Future<bool> register(String email, String password, String pseudo, String age, List<String> preferences) async {
  String cryptPass = sha1.convert(utf8.encode(password)).toString();
  try {
    UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: cryptPass
    );

    credential.user.updateProfile(displayName: pseudo);
    credential.user.sendEmailVerification();

    FirebaseFirestore.instance.collection("users").doc(credential.user.uid).set({
      "email": email,
      "pseudo": pseudo,
      "age": age,
      "preferences": preferences,
      "books": []
    });

    return true;
  } on FirebaseAuthException catch(e) {
    print(e);
    return false;
  } catch(e) {
    print(e);
    return false;
  }
}

Future<QuerySnapshot> getBooksOf(String field) {
  return FirebaseFirestore.instance.collection("books")
      .where(field, isEqualTo: FirebaseAuth.instance.currentUser.uid)
      .get();
}

Future<DocumentSnapshot> getBookWithId(String id) {
  return FirebaseFirestore.instance.collection("books").doc(id).get();
}

Future<Map<String, dynamic>> getDocument(String collection, String document) async {
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection(collection).doc(document);
  DocumentSnapshot snapshot = await documentReference.get();
  return {
    "document-reference": documentReference,
    "document-snapshot": snapshot
  };
}

Future<void> addBook(Map<String, dynamic> data) async {
  try {
    if (FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser.isAnonymous) {
      Uint8List artwork = data["artwork"];
      data["artwork"] = "";
      var book = await FirebaseFirestore.instance.collection("books").add(data);
      if (artwork != null) {
        TaskSnapshot image = await FirebaseStorage.instance.ref("artworks/${book.id}.jpg").putData(artwork);
        String url  = await image.ref.getDownloadURL();
        book.update({"artwork": url});
      }
    }
  } catch (e) {
    print(e);
  }
}

Future<void> addChapterToBook(String bookId, String name) async {
  Map<String, dynamic> document = await getDocument("books", bookId);
  DocumentSnapshot snap = document["document-snapshot"];
  List<dynamic> chapters = snap["chapters"];

  for (int i = 0; i < chapters.length; i++) {
     if (chapters[i]["name"] == name) {
       print("Key already exists");
       return false;
     }
  }
  chapters.add({
    "name": name,
    "public": false,
    "pages": []
  });
  await FirebaseFirestore.instance.collection("books")
      .doc(bookId).update({
    "chapters": chapters
      });
}

Future<List> getChapterPages(String bookId, int chapterIndex) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection("books").doc(bookId).get();
  return docSnapshot["chapters"][chapterIndex]["pages"];
}

Future<void> addPageToChapter(String bookId, int chapterIndex, String pageTitle) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection("books").doc(bookId).get();
  List<dynamic> chapters = docSnapshot["chapters"];
  for (int i = 0; i < chapters[chapterIndex]["pages"].length; i++) {
    if (chapters[chapterIndex]["pages"][i]["name"] == pageTitle) {
      print("Page already exists!");
      return false;
    }
  }
  chapters[chapterIndex]["pages"].add({
    "name": pageTitle,
    "source": ""
  });
  FirebaseFirestore.instance.collection("books").doc(bookId).update({
    "chapters": chapters
  });
}

Future<void> savePage(Delta document, String bookId, int chapterIndex, int pageIndex) async {
  String docs = json.encode(document.toJson());
  Map<String, dynamic> doc = await getDocument("books", bookId);
  DocumentReference ref = doc["document-reference"];
  DocumentSnapshot snap = doc["document-snapshot"];
  if (snap["chapters"][chapterIndex]["pages"][pageIndex]["source"].trim().isEmpty) {
    DocumentReference pageRef = await ref.collection("pages").add({"document": docs});
    List<dynamic> chapters = snap["chapters"];
    chapters[chapterIndex]["pages"][pageIndex]["source"] = pageRef.id;
    ref.update({
      "chapters": chapters
    });
  } else {
    await ref.collection("pages").doc(snap["chapters"][chapterIndex]["pages"][pageIndex]["source"]).update({
      "document": docs
    });
  }
}

Future<NotusDocument> loadPage(String bookId, int chapterIndex, int pageIndex) async {
  Map<String, dynamic> document = await getDocument("books", bookId);
  DocumentReference ref = document["document-reference"];
  DocumentSnapshot snap = document["document-snapshot"];
  if (snap["chapters"][chapterIndex]["pages"][pageIndex]["source"].trim().isEmpty) {
    Delta delta = Delta();
    delta.insert("\n");
    return NotusDocument.fromDelta(delta);
  } else {
    DocumentSnapshot doc = await ref.collection("pages").doc(snap["chapters"][chapterIndex]["pages"][pageIndex]["source"]).get();
    Delta delta = Delta();
    return NotusDocument.fromJson(json.decode(doc["document"]));
  }
}

Future<void> publishChapter(String bookId, String chapter) async {
  Map<String, dynamic> document = await getDocument("books", bookId);
  DocumentReference ref = document["document-reference"];
  DocumentSnapshot snap = document["document-snapshot"];
}

Future<void> renameChapter(String bookId, int chapterIndex, String value) async {
  Map<String, dynamic> document = await getDocument("books", bookId);
  DocumentReference ref = document["document-reference"];
  DocumentSnapshot snap = document["document-snapshot"];
  List<dynamic> chapters = snap["chapters"];
  for (int i = 0; i < chapters.length; i++) {
    if (chapters[i]["name"] == value) {
      print("Key already exists");
      return false;
    }
  }
  chapters[chapterIndex]["name"] = value;
  await ref.update({
    "chapters": chapters
  });
}

Future<void> moveUpChapter(String bookId, int chapterIndex) async {

}

Future<void> moveDownChapter(String bookId, int chapterIndex) async {

}