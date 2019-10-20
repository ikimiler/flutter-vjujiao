import 'dart:async';
import 'package:app/utils/sp.dart';
import 'package:flutter/material.dart';
import './pages/splash.dart';
import './widget/basestate.dart';
import './utils/eventbus.dart';
import './utils/constant.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends BaseState<MyApp> {
  StreamSubscription subscription;
  Color themeColor = Colors.red;

  @override
  void initState() {
    super.initState();
    getInt(Constant.THEME_COLOR).then((value) {
      if (value != null) {
        setState(() {
          themeColor = Color(value);
        });
      }
    });
    subscription = eventBus.on<EventAction>().listen((event) {
      if (event.action == EventAction.CHANGE_THEME_ACTION) {
        if (themeColor == event.data) return;
        putInt(Constant.THEME_COLOR, event.data.value);
        setState(() {
          themeColor = event.data;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription.cancel();
    }
  }

  getTheme() {
    if (themeColor.value == Colors.black.value) {
      return ThemeData(brightness: Brightness.dark, buttonColor: Colors.black);
    } else {
      return ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: themeColor,
        buttonColor: themeColor,
        cursorColor: themeColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V聚焦',
      theme: getTheme(),
      home: Splash(),
    );
  }
}
