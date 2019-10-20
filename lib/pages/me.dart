import 'dart:convert';
import 'package:app/pages/applyRSS.dart';
import 'package:app/pages/mycollectlist.dart';
import 'package:app/pages/systemMsg.dart';
import 'package:app/utils/sp.dart';
import 'package:flutter/material.dart';
import './mysubrsslist.dart';
import '../widget/basestate.dart';
import '../utils/constant.dart';
import './systemSetting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Me extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MeState();
  }
}

class MeState extends BaseState<Me> {
  Map userinfo = Constant.defaultUserinfo;

  initState() {
    super.initState();
    getStr(Constant.USER_INFO).then((value) {
      if (value != null) {
        var jsonMap = json.decode(value);
        setState(() {
          userinfo = jsonMap;
        });
      }
    });
  }

  List<Widget> headerSliverBuilder(
      BuildContext context, bool innerBoxIsScrolled) {
    var date = DateTime.now();
    var year = date.year;
    var month = date.month;
    var day = date.day;
    var idxArray = ['一', '二', '三', '四', '五', '六', '日'];
    var weekday = idxArray[date.weekday - 1];

    return <Widget>[
      SliverAppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SystemMsg();
              }));
            },
            icon: Icon(FontAwesomeIcons.comment),
          )
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('欢迎您 ${userinfo["name"]}',
                      style: TextStyle(color: Colors.white)),
                  Container(height: 10),
                  Text('今天是 $year年 $month月 $day日 周$weekday',
                      style: TextStyle(color: Colors.white)),
                  Container(height: 10),
                  Text(userinfo["email"],
                      style: TextStyle(color: Colors.white)),
                ],
              )),
        ),
        expandedHeight: 200,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: headerSliverBuilder,
      body: ListView(
        children: <Widget>[
          ListTile(
            dense: false,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MySubRssList();
              }));
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text("我的订阅"),
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            dense: false,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MyCollectList();
              }));
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text("我的收藏"),
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            dense: false,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ApplyRSS();
              }));
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text("申请栏目"),
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            dense: false,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SystemSetting();
              }));
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text("系统设置"),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
