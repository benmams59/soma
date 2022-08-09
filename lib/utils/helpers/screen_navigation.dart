import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ScreenNavigation {

  static Future<dynamic> navigate(BuildContext context, Widget routeWidget) {
    final builder = (BuildContext context) {
      return routeWidget;
    };
    return Navigator.push(context, Platform.isIOS ?
      CupertinoPageRoute(builder: builder)
      :
      MaterialPageRoute(builder: builder)
    );
  }
}