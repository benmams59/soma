import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/helpers/helpers.dart' as helpers;
import 'package:soma/utils/services/db_services.dart' as services;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _usernameController;
  TextEditingController _passwordController;

  List<int> _error = [];
  ValueNotifier<int> _timer = ValueNotifier(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _passwordController.dispose();
    if (FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser.emailVerified)
      FirebaseAuth.instance.signOut();
    super.dispose();
  }

  void _resendEmailVerification() async {
    _timer.value = 180;
    await FirebaseAuth.instance.currentUser.sendEmailVerification();
    _subtractTimer();
  }

  void _subtractTimer() {
    if (_timer.value > 0) {
      _timer.value--;
      Timer(Duration(seconds: 1), _subtractTimer);
    }
  }

  void _login() async {
    setState(() => _error.clear());
    helpers.loadingScreen(
      context: context,
      message: "Connexion..."
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: sha1.convert(utf8.encode(_passwordController.text)).toString()
      ).then((value) {
        if (!value.user.emailVerified) {
          setState(() => _error.add(0));
          Navigator.pop(context);
        } else {
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      });
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case "invalid-email": setState(() => _error.add(1));
        break;
        case "user-not-found": setState(() => _error.add(2));
        break;
        case "wrong-password": setState(() => _error.add(3));
        break;
        case "network-request-failed": setState(() => _error.add(4));
        break;
      }
      print(e.code);
      Navigator.pop(context);
    } catch(e) {
      print(e);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          child: CustomListView(
            title: "Login",
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (change) {
                    setState(() {
                      _error.remove(1);
                      _error.remove(2);
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Username",
                      border: InputBorder.none,
                    errorText: _error.contains(1) ?
                        "Invalid email"
                        :
                        _error.contains(2) ?
                            "Username not found"
                            :
                        null
                  ),
                ),
              ),
              Divider(height: 1,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _passwordController,
                  onChanged: (change) => setState(() => _error.remove(3)),
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      errorText: _error.contains(3) ? "Wrong password" : null
                  ),
                ),
              ),
              Divider(height: 1,),
              if (_error.contains(0))
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                color: Colors.orangeAccent,
                height: 45,
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 10,),
                    Text("You must verify your email!",),
                    Spacer(flex: 1,),
                    ValueListenableBuilder<int>(
                      valueListenable: _timer,
                      builder: (context, value, child) {
                        if (value == 0) {
                          return TextButton(
                            onPressed: () => _resendEmailVerification(),
                            child: Text("Resend", style: TextStyle(color: Colors.black),),
                          );
                        }

                        if (value > 0) {
                          return Text(
                              "$value"
                          );
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              if (_error.contains(4))
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  color: Colors.orangeAccent,
                  child: Row(
                    children: [
                      Icon(Icons.signal_wifi_off_outlined),
                      SizedBox(width: 10,),
                      Text("Network request failed!",),
                      Spacer(flex: 1,),
                      IconButton(
                        onPressed: () => _error.remove(4),
                        icon: Icon(Icons.close_outlined),
                      )
                    ],
                  ),
                ),
              Divider(height: 1,),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _login(),
                  child: Text("Connexion"),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15)
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