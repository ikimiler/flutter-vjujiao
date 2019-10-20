import 'package:flutter/material.dart';
import '../widget/basestate.dart';

class OpenSource extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OpenSourcetate();
  }
}

class OpenSourcetate extends BaseState<OpenSource> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("开源组件"),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: <Widget>[
                Text(""),
                Text(""),
              ]);
        }));
  }
}
