import 'package:flutter/material.dart';

void showToast(context, text) {
  try {
    var snackBar = new SnackBar(
        content: new Text(text),
        duration: Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor);
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  } catch (e) {}
}
