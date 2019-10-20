import 'package:app/utils/sp.dart';
import 'package:flutter/material.dart';
import './subscriptionIndex.dart';
import './me.dart';
import './index.dart';
import '../utils/eventbus.dart';
import '../utils/constant.dart';
import '../widget/basestate.dart';
import 'dart:async';
import './login.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import '../net/http.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  final List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(title: Text("首页"), icon: Icon(Icons.home)),
    BottomNavigationBarItem(title: Text("广场"), icon: Icon(Icons.public)),
    BottomNavigationBarItem(title: Text("我的"), icon: Icon(Icons.portrait)),
  ];
  int currentIndex = 0;
  List<Widget> pages = <Widget>[Index(), SubscriptionIndex(), Me()];
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = eventBus.on<EventAction>().listen((event) {
      if (event.action == EventAction.INVALIDATE_TOKEN_ACTION) {
        showTokenInvalidateAlertDialog();
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      checkApp();
    });
  }

  checkApp() async {
    var response = await http2.get("/config/config.json");
    if (response != null && response.data != null) {
      if (Platform.isAndroid) {
        var androidNewVersion = response.data["android_new_version"];
        var android_download_url = response.data["android_download_url"];
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        if (int.parse(androidNewVersion.toString()) >
            int.parse(packageInfo.buildNumber.toString())) {
          showDownloadAlertDialog(android_download_url);
        }
      } else if (Platform.isIOS) {}
    }
  }

  showDownloadAlertDialog(url) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context2) {
          return AlertDialog(
            content: Text("发现最新版本,请立即更新"),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("取消"),
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  startDownload(url);
                },
                child: Text("确定"),
              )
            ],
          );
        });
  }

  startDownload(url) async {
    try {
      Directory directory = await getExternalStorageDirectory();
      Directory directory2 = Directory(directory.path + "/vjujiao");
      var exists = await directory2.exists();
      if (!exists) {
        await directory2.create();
      }
      File file = File(directory2.path + "/vjujiao.apk");
      var response = await Dio().get(url,
          onReceiveProgress: (int count, int total) {
        print("download progress &count $total");
      },
          options: Options(
              responseType: ResponseType.bytes, followRedirects: false));
      file.createSync();
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      print("download -success");
      await OpenFile.open(file.path);
    } catch (e) {
      print("download error $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription.cancel();
    }
  }

  showTokenInvalidateAlertDialog() {
    if (Constant.showTokenTipsDialog) return;
    Constant.showTokenTipsDialog = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context2) {
          return AlertDialog(
            content: Text("你的token已过期,请重新登录"),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  await putStr(Constant.TOKEN, "");
                  await Navigator.of(context).pop();
                  await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (BuildContext context) {
                    return Login();
                  }), (router) => false);
                  Constant.showTokenTipsDialog = false;
                },
                child: Text("确定"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        // selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: WillPopScope(
          onWillPop: _onWillPop,
          child: IndexedStack(index: currentIndex, children: pages)),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('提示:'),
            content: new Text('你确定要退出app吗'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('取消'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('确认'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
