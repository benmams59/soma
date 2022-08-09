import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/add_book_screen.dart';
import 'package:soma/screens/category_fragment.dart';
import 'package:soma/screens/library_fragment.dart';
import 'package:soma/screens/login_screen.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/helpers/screen_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soma',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
        primaryColor: Color.fromRGBO(245, 177, 32, 1),
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Soma'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentScreenIndex = 0;

  static List<Widget> _screens = [
    Text("Explore"),
    CategoryFragment(),
    LibraryFragment()
  ];

  _onBottomNavigationItemTapped(int index) {
    setState(() => _currentScreenIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: Icon(Icons.search_outlined),
          ),
          IconButton(
            onPressed: () => ScreenNavigation.navigate(context, ProfileScreen()),
            icon: Icon(Icons.person_outlined)
          )
        ],
      ),
      body: _screens.elementAt(_currentScreenIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => _onBottomNavigationItemTapped(index),
        currentIndex: _currentScreenIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: "Explore"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              label: "Category"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              label: "Library"
          )
        ],
      ),
      floatingActionButton: _currentScreenIndex == 2 ? FloatingActionButton(
        onPressed: () {
          if (FirebaseAuth.instance.currentUser != null &&
          !FirebaseAuth.instance.currentUser.isAnonymous) {
            ScreenNavigation.navigate(context, AddBookScreen()).then((value) => setState(() => {}));
          } else {
            ScreenNavigation.navigate(context, LoginScreen()).then((value) => setState(() => {}));
          }
        },
        child: Icon(Icons.edit_outlined),
      ) : null,
    );
  }
}
