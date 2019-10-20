import 'package:app/pages/movewebview.dart';
import 'package:app/widget/networkImageWrapper.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import '../net/http.dart';
import './rssdetail.dart';
import '../widget/basestate.dart';
import '../utils/toast.dart';
import '../widget/refreshList.dart';
import '../utils/eventbus.dart';
import 'dart:async';
import '../widget/networkWrapper.dart';

class RssList extends StatefulWidget {
  String name;
  int tag_id;
  RssList(this.name, this.tag_id);

  @override
  State<StatefulWidget> createState() {
    return RssListState();
  }
}

class RssListState extends BaseState<RssList> {
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

  @override
  void initState() {
    super.initState();
    subscription = eventBus.on<EventAction>().listen((eventAction) {
      var id = eventAction.data;
      datas.forEach((item) {
        if (item["rss_id"] == id) {
          if (eventAction.action == EventAction.SUB_RSS_SUCCESS_ACTION) {
            item["hasSub"] = 1;
          } else if (eventAction.action ==
              EventAction.UNSUB_RSS_SUCCESS_ACTION) {
            item["hasSub"] = 0;
          }
        }
      });
      setState(() {});
    });

    requestHttp();
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription.cancel();
    }
  }

  subRss(context, id) async {
    try {
      var params = {"id": id};
      var response = await http2.post("/app/user/rss/subRss", data: params);
      if (response.data["code"] == 200) {
        showToast(context, "订阅成功");
        eventBus.fire(EventAction(EventAction.SUB_RSS_SUCCESS_ACTION, id));
      } else {
        showToast(context, "订阅失败");
      }
    } catch (e) {
      print(e);
      showToast(context, "订阅失败");
    }
  }

  unsubRss(context, id) async {
    try {
      var params = {"id": id};
      var response = await http2.post("/app/user/rss/unSubRss", data: params);
      if (response.data["code"] == 200) {
        showToast(context, "取消订阅成功");
        eventBus.fire(EventAction(EventAction.UNSUB_RSS_SUCCESS_ACTION, id));
      } else {
        showToast(context, "取消订阅失败");
      }
    } catch (e) {
      print(e);
      showToast(context, "取消订阅失败");
    }
  }

  NetworkStatus currentNetwokStatus = NetworkStatus.Loading;
  requestHttp() async {
    if (pageIndex == 0 && currentNetwokStatus == NetworkStatus.Fail) {
      setState(() {
        currentNetwokStatus = NetworkStatus.Loading;
      });
    }
    try {
      var params = {
        "offset": pageIndex * pageSize,
        "limit": pageSize,
        "tag_id": widget.tag_id
      };
      var response =
          await http2.get("/app/user/tag/rss", queryParameters: params);
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
    String tag = 'rss_image2_${item["name"]}';
    bool hasSub = item["hasSub"] == 1;

    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            if (item["type"] == 1) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return RssDetail(
                  item["rss_id"],
                  tag: tag,
                );
              }));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MoveWebview(
                  item["rss_url"],
                  item["name"],
                );
              }));
            }
          },
          dense: false,
          leading: Hero(
            tag: tag,
            child: NetworkImageWrapper(
              item["logo"],
              width: 25,
              height: 25,
            ),
          ),
          trailing: InkResponse(
            onTap: () {
              hasSub
                  ? unsubRss(context, item["rss_id"])
                  : subRss(context, item["rss_id"]);
            },
            child: Icon(hasSub ? Icons.favorite : Icons.favorite_border,
                color: hasSub ? Theme.of(context).primaryColor : Colors.black),
          ),
          title: Text(item["name"]),
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
        title: Text(widget.name),
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
            )),
      ),
    );
  }
}
