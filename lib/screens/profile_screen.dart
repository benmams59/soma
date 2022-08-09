import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/login_screen.dart';
import 'package:soma/screens/register_screen.dart';
import 'package:soma/utils/helpers/screen_navigation.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              CustomListView(
                title: "Accounts",
                children: [
                  if (FirebaseAuth.instance.currentUser == null ||
                  FirebaseAuth.instance.currentUser.isAnonymous)
                    ListTile(
                      onTap: () => ScreenNavigation.navigate(context, LoginScreen()).then((value) => setState(() {})),
                      title: Text("Log in"),
                      trailing: Icon(Icons.navigate_next),
                    ),
                  if (FirebaseAuth.instance.currentUser != null &&
                  !FirebaseAuth.instance.currentUser.isAnonymous)
                    ListTile(
                      onTap: () => _signOut(),
                      title: Text("Sign out", style: TextStyle(
                        color: Colors.red
                      )),
                      trailing: Icon(Icons.navigate_next),
                    ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => ScreenNavigation.navigate(context, RegisterScreen()),
                    title: Text("Register"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  Divider(height: 1,),
                  if (FirebaseAuth.instance.currentUser != null)
                  ListTile(
                    title: Text("Profile"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              CustomListView(
                title: "Settings",
                children: [
                  ListTile(
                    onTap: () => {},
                    title: Text("Appearance"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => {},
                    title: Text("Notifications"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              CustomListView(
                title: "About",
                children: [
                  ListTile(
                    onTap: () => {},
                    title: Text("Privacy"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => {},
                    title: Text("Help"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  Divider(height: 1,),
                  ListTile(
                    onTap: () => {},
                    title: Text("About"),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ],
              )
            ]
          ),
        ),
      ),
    );
  }
}

class CustomListView extends StatelessWidget {
  CustomListView({
    Key key,
    this.title,
    this.elevation = 0.1,
    this.children,
  }) : super(key: key);

  final String title;
  final List<Widget> children;
  final double elevation;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 15),
          child: Text(title, style: ProfileTextStyle.header,),
        ),
        SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: elevation,
                color: Colors.black38
              )
            ]
          ),
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}

class ProfileTextStyle {
  static final TextStyle header = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}