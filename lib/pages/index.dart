import 'package:app/net/http.dart';
import 'package:app/pages/search.dart';
import 'package:app/utils/eventbus.dart';
import 'package:app/widget/networkImageWrapper.dart';
import 'package:app/widget/networkWrapper.dart';
import 'package:flutter/material.dart';
import './webview.dart';
import '../widget/basestate.dart';
import '../widget/refreshList.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'dart:async';

class Index extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndexState();
  }
}

class IndexState extends BaseState<Index> {
  List<dynamic> datas = [];
  int pageIndex = 0, pageSize = 5;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool firstRefresh = false;

  NetworkStatus currentNetwokStatus = NetworkStatus.Loading;

  StreamSubscription subscription;

  @override
  initState() {
    super.initState();
    subscription = eventBus.on<EventAction>().listen((event) {
      if (event.action == EventAction.SUB_RSS_SUCCESS_ACTION) {
        requestHttp();
      }
    });
    requestHttp();
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
          await http2.get("/app/user/index", queryParameters: params);
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

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription.cancel();
    }
  }

  Widget buildChildItem(item, index) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return WebViewPage(item);
          }));
        },
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0,right: 10),
          leading: Container(
            width: 48,
            child: Center(
              child: Container(
                width: 1,
                color: Colors.black26,
              ),
            ),
          ),
          title: Text(
            item["title"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }

  Widget buildItem(context, index) {
    var item = datas[index];
    if (index > 0 && datas[index - 1]["name"] == item["name"]) {
      return buildChildItem(item, index);
    } else {
      var name = item["name"];
      var timespan = item["timespan"];
      return Column(
        children: <Widget>[
          ListTile(
              contentPadding: EdgeInsets.only(left: 0,right: 10),
              leading: Container(
                width: 48,
                height: 48,
                child: Center(
                  child: NetworkImageWrapper(
                    item["logo"],
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(timespan)),
          buildChildItem(item, IndexedStack)
        ],
      );
    }
  }

  Future<void> onRefresh() async {
    pageIndex = 0;
    await requestHttp();
  }

  Future<void> onLoadMore() async {
    pageIndex++;
    await requestHttp();
  }

  buildCustomEmptyWidget() {
    var screen = MediaQuery.of(context);
    return Container(
      width: screen.size.width,
      height:
          screen.size.height - screen.padding.top - screen.padding.bottom - 112,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("你还没有订阅任何栏目"),
          Container(
            height: 5,
          ),
          Text("请去广场订阅")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("V聚焦"),
          actions: <Widget>[
            IconButton(
              tooltip: "搜索",
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return Search(
                    type: 1,
                  );
                }));
              },
              icon: Icon(Icons.search),
            )
          ],
        ),
        body: NetworkWrapper(
            networkStatus: currentNetwokStatus,
            retryInit: requestHttp,
            emptyAndRefresh: true,
            child: RefreshList(
                emptyWidget: buildCustomEmptyWidget(),
                easyRefreshKey: _easyRefreshKey,
                headerKey: _headerKey,
                footerKey: _footerKey,
                firstRefresh: firstRefresh,
                onRefresh: onRefresh,
                onLoadmore: onLoadMore,
                child: ListView.builder(
                  itemCount: datas.length,
                  itemBuilder: buildItem,
                ))));
  }
}
