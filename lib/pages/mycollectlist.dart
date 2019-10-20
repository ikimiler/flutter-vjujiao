import 'package:app/pages/webview.dart';
import 'package:app/widget/networkImageWrapper.dart';
import 'package:flutter/material.dart';
import '../net/http.dart';
import './rssdetail.dart';
import '../widget/basestate.dart';
import '../widget/refreshList.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../utils/eventbus.dart';
import 'dart:async';
import '../widget/networkWrapper.dart';

class MyCollectList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyCollectListState();
  }
}

class MyCollectListState extends BaseState<MyCollectList> {
  List<dynamic> datas = [];
  int pageIndex = 0, pageSize = 20;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool firstRefresh = false;
  StreamSubscription subscription;
  NetworkStatus currentNetwokStatus = NetworkStatus.Loading;

  @override
  void initState() {
    super.initState();
    // subscription = eventBus.on<EventAction>().listen((eventAction) {
    //   if (eventAction.action == EventAction.SUB_RSS_SUCCESS_ACTION) {
    //     pageIndex = 0;
    //     requestHttp();
    //   } else if (eventAction.action == EventAction.UNSUB_RSS_SUCCESS_ACTION) {
    //     pageIndex = 0;
    //     requestHttp();
    //   }
    // });
    requestHttp();
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription.cancel();
    }
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
          await http2.get("/app/user/rss/collect", queryParameters: params);
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
    return Column(
      children: <Widget>[
        ListTile(
          dense: false,
          onTap: () {
            item["rss_id"] = item["target_rss_id"];
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return WebViewPage(item);
            }));
          },
          title: Text(
            item["title"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Divider(
          height: 1,
        )
      ],
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
          title: Text("我的收藏"),
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
              itemCount: datas.length,
              itemBuilder: buildItem,
            ),
          ),
        ));
  }
}
