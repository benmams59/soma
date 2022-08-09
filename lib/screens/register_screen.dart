import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:soma/screens/login_screen.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/helpers/helpers.dart' as helpers;
import 'package:soma/utils/helpers/screen_navigation.dart';
import 'package:soma/widgets/toggle_chip.dart';
import 'package:soma/utils/services/db_services.dart' as services;

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  TextEditingController _pseudoController;
  TextEditingController _ageController;
  PageController _pageController;

  List<int> _error = [];


  List<String> _fiction = [];
  List<String> _nonFiction = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _pseudoController = TextEditingController();
    _ageController = TextEditingController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _pseudoController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  _nextToPersonalInfo() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirm = _confirmController.text;

    FocusScope.of(context).unfocus();
    _error.clear();
    if (!helpers.emailRegex(email))
      _error.add(0);
    if (!helpers.passwordRegex(password))
      _error.add(1);
    if (password != confirm)
      _error.add(2);

    if (_error.length > 0) {
      setState(() {});
      return;
    }

    helpers.loadingScreen(
      context: context,
      message: "Wait...",
    );
    bool isEmailExist = await services.fieldExist("users", "email", email);
    if (isEmailExist) {
      _error.add(3);
      setState(() { });
      return;
    }
    Navigator.pop(context);
    _pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  Future<void> _nextToPreferences() async {
    String pseudo = _pseudoController.text;
    String age = _ageController.text;

    FocusScope.of(context).unfocus();
    _error.clear();
    if (pseudo.trim().length < 3) {
      _error.add(4);
    }
    if (!RegExp(r"^[0-9]{1,3}$").hasMatch(age))
      _error.add(5);
    else {
      if (!(int.tryParse(age) >= 7 && int.tryParse(age) <= 120))
        _error.add(5);
    }

    if(_error.length > 0) {
      setState(() { });
      return;
    }

    helpers.loadingScreen(
      context: context,
      message: "Wait...",
    );
    bool isPseudoExist = await services.fieldExist("users", "pseudo", pseudo);
    if (isPseudoExist) {
      _error.add(4);
      setState(() { });
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);

    _pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  Future<void> _nextToMessage() async {
    List<String> preferences = [..._fiction, ..._nonFiction];
    helpers.loadingScreen(
      context: context,
      message: "Wait...",
    );
    await services.register(
        _emailController.text,
        _passwordController.text,
        _pseudoController.text,
        _ageController.text,
        preferences
    );
    Navigator.pop(context);
    _pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  Widget _emailAndPassWidgets() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CustomListView(
              title: "Email and password",
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    onChanged: (change) => setState(() { _error.remove(0); }),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: "Email",
                        border: InputBorder.none,
                        errorText: _error.contains(0) ? "Bad email" : _error.contains(3) ? "Email is already exist" : null
                    ),
                  ),
                ),
                Divider(height: 1,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    onChanged: (change) => setState(() { _error.remove(1); }),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Password",
                        border: InputBorder.none,
                        errorText: _error.contains(1) ? "Weak password" : null
                    ),
                  ),
                ),
                Divider(height: 1,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    onChanged: (change) => setState(() { _error.remove(2); }),
                    controller: _confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Confirm password",
                        border: InputBorder.none,
                        errorText: _error.contains(2) ? "Bad password confirmation" : null
                    ),
                  ),
                ),
                Divider(height: 1,),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _nextToPersonalInfo(),
                    child: Text("Connexion"),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15)
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _personalInformationWidgets() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CustomListView(
              title: "Personal information",
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _pseudoController,
                    onChanged: (change) => setState(() => _error.remove(4)),
                    decoration: InputDecoration(
                        hintText: "Pseudo",
                        border: InputBorder.none,
                        errorText: _error.contains(4) ? "Pseudo already exists" : null
                    ),
                  ),
                ),
                Divider(height: 1,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _ageController,
                    onChanged: (change) => setState(() => _error.remove(5)),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Age",
                        border: InputBorder.none,
                        errorText: _error.contains(5) ? "Age is not available" : null
                    ),
                  ),
                ),
                Divider(height: 1,),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _nextToPreferences(),
                    child: Text("Ok"),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15)
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _preferenceWidgets() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text("Preferences (minimum 5)", style: ProfileTextStyle.header),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 45),
              child: Text("Fiction", style: ProfileTextStyle.header),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Wrap(
                children: helpers.categories["fiction"].map((e) => InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      if (_fiction.contains(e))
                        _fiction.remove(e);
                      else _fiction.add(e);
                    });
                  },
                  child: ToggleChip(
                    child: Text(e, style: Theme.of(context).textTheme.subtitle1,),
                    selected: _fiction.contains(e),
                  ),
                )).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 0),
              child: Text("Non-fiction", style: ProfileTextStyle.header),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Wrap(
                children: helpers.categories["non-fiction"].map((e) => InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      if (_nonFiction.contains(e))
                        _nonFiction.remove(e);
                      else _nonFiction.add(e);
                    });
                  },
                  child: ToggleChip(
                    child: Text(e, style: Theme.of(context).textTheme.subtitle1,),
                    selected: _nonFiction.contains(e),
                  ),
                )).toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _nonFiction.length + _fiction.length >= 5 ? () => _nextToMessage() : null,
                child: Text("Finish"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          _emailAndPassWidgets(),
          _personalInformationWidgets(),
          _preferenceWidgets(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text("We sent you an email to verify your account.", style: ProfileTextStyle.header,),
                Spacer(flex: 1,),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScreenNavigation.navigate(context, LoginScreen());
                    },
                    child: Text("Ok"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}