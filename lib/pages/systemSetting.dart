import 'dart:convert';
import 'package:app/net/http.dart';
import 'package:app/pages/applyRSS.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/openSource.dart';
import 'package:app/pages/resetPassword.dart';
import 'package:app/utils/sp.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import '../widget/basestate.dart';
import '../utils/eventbus.dart';
import './feedback.dart';
import '../utils/constant.dart';
import './about.dart';

class SystemSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SystemSettingState();
  }
}

class SystemSettingState extends BaseState<SystemSetting> {
  var colors = [
    ColorModel("暗黑", Colors.black),
    ColorModel("红色", Colors.red),
    ColorModel("蓝色", Colors.blue),
    ColorModel("绿色", Colors.green),
    ColorModel("粉红", Colors.pink),
    ColorModel("紫色", Colors.purple),
  ];
  Map userinfo = Constant.defaultUserinfo;
  String versionName = "1.0.0";

  @override
  initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info){
      setState((){
        versionName = info.version;
      });
    });
    getStr(Constant.USER_INFO).then((value) {
      if (value != null) {
        var jsonMap = json.decode(value);
        setState(() {
          userinfo = jsonMap;
        });
      }
    });
  }

  showColorsModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: ListView(
                children: colors.map((color) {
              Widget view = Column(
                children: <Widget>[
                  ListTile(
                    dense: false,
                    onTap: () {
                      eventBus.fire(EventAction(
                          EventAction.CHANGE_THEME_ACTION, color.color));
                    },
                    title: Text(
                      color.name,
                      style: TextStyle(color: color.color),
                    ),
                  ),
                  Divider(
                    height: 1,
                  )
                ],
              );
              return view;
            }).toList()),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("系统设置"),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              ListTile(
                dense: false,
                onTap: () {
                  showColorsModalBottomSheet(context);
                },
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text("更换主题"),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                dense: false,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return FeedbackPage();
                  }));
                },
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text("意见反馈"),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                dense: false,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return ResetPassword(
                      email: userinfo["email"],
                    );
                  }));
                },
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text("重设密码"),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                dense: false,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return AboutPage();
                  }));
                },
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text("关于我们"),
              ),
              Divider(
                height: 1,
              ),
              // ListTile(
              //   dense: false,
              //   onTap: () {
              //     Navigator.of(context)
              //         .push(MaterialPageRoute(builder: (BuildContext context) {
              //       return OpenSource();
              //     }));
              //   },
              //   trailing: Icon(Icons.keyboard_arrow_right),
              //   title: Text("开源组件"),
              // ),
              // Divider(
              //   height: 1,
              // ),
              Container(
                width: 300,
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: RaisedButton(
                  onPressed: () {
                    logout(context);
                  },
                  child: Text(
                    "退出登录",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 80),
                alignment: Alignment.bottomCenter,
                child: Text('version $versionName'),
              )
            ],
          );
        }));
  }

  logout(context) {
    putStr(Constant.TOKEN, "").then((value) {
      authorization();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) {
        return Login();
      }), (router) => false);
    });
  }
}

class ColorModel {
  String name;
  Color color;
  ColorModel(this.name, this.color);
}
