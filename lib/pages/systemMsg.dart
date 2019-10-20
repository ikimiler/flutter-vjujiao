import 'package:flutter/material.dart';
import '../net/http.dart';
import '../widget/basestate.dart';
import '../widget/refreshList.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'dart:async';
import '../widget/networkWrapper.dart';

class SystemMsg extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SystemMsgState();
  }
}

class SystemMsgState extends BaseState<SystemMsg> {
  List<dynamic> datas = [];
  int pageIndex = 0, pageSize = 20;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool firstRefresh = false;
  NetworkStatus currentNetwokStatus = NetworkStatus.Loading;

  @override
  void initState() {
    super.initState();
    requestHttp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  requestHttp() async {
    if (pageIndex == 0 && currentNetwokStatus == NetworkStatus.Fail) {
      setState(() {
        currentNetwokStatus = NetworkStatus.Loading;
      });
    }
    try {
      var params = {"offset": pageIndex * pageSize, "limit": pageSize};
      var response =
          await http2.get("/app/user/systemMsg", queryParameters: params);
      if (response.data["code"] == 200) {
        setState(() {
          if (pageIndex == 0) {
            datas = response.data["data"];
            currentNetwokStatus = response.data["data"].length == 0
                ? NetworkStatus.Empty
                : NetworkStatus.Success;
          } else {
            datas.addAll(response.data["data"]);
          }
        });
      } else {
        if (pageIndex == 0) {
          setState(() {
            currentNetwokStatus = NetworkStatus.Fail;
          });
        }
      }
    } catch (e) {
      print(e);
      if (pageIndex == 0) {
        setState(() {
          currentNetwokStatus = NetworkStatus.Fail;
        });
      }
    } finally {
      // setState(() {
      //   firstRefresh = false;
      // });
    }
  }

  Widget buildItem(context, index) {
    var item = datas[index];
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(item["time"]));
    var year = date.year;
    var month = date.month;
    var day = date.day;
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(item["text"]),
            Text("$year年$month月$day日"),
          ],
        ),
      ),
    );
  }

  Future<void> onRefresh() async {
    pageIndex = 0;
    await requestHttp();
  }

  Future<void> onLoadMore() async {
    pageIndex++;
    await requestHttp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("系统消息"),
        ),
        body: NetworkWrapper(
          networkStatus: currentNetwokStatus,
          retryInit: requestHttp,
          child: RefreshList(
            easyRefreshKey: _easyRefreshKey,
            headerKey: _headerKey,
            footerKey: _footerKey,
            firstRefresh: firstRefresh,
            onRefresh: onRefresh,
            onLoadmore: onLoadMore,
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: datas.length,
              itemBuilder: buildItem,
            ),
          ),
        ));
  }
}
