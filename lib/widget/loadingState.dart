import 'package:flutter/material.dart';

enum LoadingStatus { Running, Success, Fail, Empty }

class LoadingState<T extends StatefulWidget> extends State<T> {
  LoadingStatus currentLoadingStatus = LoadingStatus.Running;

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {}

  buildRunningWidget() {
    return Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.black),
    ));
  }

  buildEmptyWidget() {
    return Center(child: Text("空空如也～"));
  }

  buildFailWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("加载出错,请重试"),
        RaisedButton(
          color: Colors.black,
          onPressed: initData,
          child: Text(
            "重试",
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  buildSuccessWidget() {}

  @override
  Widget build(BuildContext context) {
    if (currentLoadingStatus == LoadingStatus.Empty) {
      return buildEmptyWidget();
    } else if (currentLoadingStatus == LoadingStatus.Fail) {
      return buildFailWidget();
    } else if (currentLoadingStatus == LoadingStatus.Success) {
      return buildSuccessWidget();
    } else if (currentLoadingStatus == LoadingStatus.Running) {
      return buildRunningWidget();
    } else {
      return null;
    }
  }
}
