import 'package:flutter/material.dart';
import '../widget/basestate.dart';

enum NetworkStatus {
  Loading,
  Fail,
  Success,
  Empty,
  NetworkDisable,
}

class NetworkWrapper extends StatefulWidget {
  NetworkStatus networkStatus;
  Widget child;
  VoidCallback retryInit;
  bool emptyAndRefresh;
  NetworkWrapper({
    this.child,
    this.networkStatus = NetworkStatus.Loading,
    this.retryInit,
    this.emptyAndRefresh = false,
  });

  @override
  State<StatefulWidget> createState() {
    return NetworkWrapperState();
  }
}

class NetworkWrapperState extends BaseState<NetworkWrapper> {
  buildSuccess() {
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (widget.networkStatus) {
      case NetworkStatus.Empty:
        content = widget.emptyAndRefresh ? buildSuccess() : EmptyWidget();
        break;
      case NetworkStatus.Success:
        content = buildSuccess();
        break;
      case NetworkStatus.Fail:
        content = ErrorWidget(onTap: () {
          widget.retryInit();
        });
        break;
      case NetworkStatus.Loading:
        content = LoadingWidget();
        break;
      default:
        content = Container();
    }

    return Container(
      child: content,
    );
  }
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            ),
          ),
          Container(
            height: 10,
          ),
          Text("拼命加载中...")
        ],
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("暂时没有相关数据哦~"),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  var onTap;
  ErrorWidget({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Text("加载失败了~",style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
