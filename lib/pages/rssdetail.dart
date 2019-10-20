import 'package:app/utils/constant.dart';
import 'package:app/widget/networkImageWrapper.dart';
import 'package:flutter/material.dart';
import '../net/http.dart';
import './webview.dart';
import '../widget/basestate.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../utils/eventbus.dart';
import '../utils/toast.dart';
import '../widget/networkWrapper.dart';

class RssDetail extends StatefulWidget {
  int rss_id;
  String tag;
  RssDetail(this.rss_id, {this.tag = "rss_image"});

  @override
  State<StatefulWidget> createState() {
    return RssDetailState();
  }
}

class RssDetailState extends BaseState<RssDetail> with HeaderListener {
  dynamic rssinfo = Constant.defaultRssinfo;

  List<dynamic> datas = [];
  int pageIndex = 0, pageSize = 20;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  subRss(context) async {
    try {
      var params = {"id": widget.rss_id};
      var response = await http2.post("/app/user/rss/subRss", data: params);
      if (response.data["code"] == 200) {
        setState(() {
          rssinfo["hasSub"] = 1;
        });
        showToast(context, "订阅成功");
        eventBus.fire(
            EventAction(EventAction.SUB_RSS_SUCCESS_ACTION, widget.rss_id));
      } else {
        showToast(context, "订阅失败");
      }
    } catch (e) {
      print(e);
      showToast(context, "订阅失败");
    }
  }

  unsubRss(context) async {
    try {
      var params = {"id": widget.rss_id};
      var response = await http2.post("/app/user/rss/unSubRss", data: params);
      if (response.data["code"] == 200) {
        setState(() {
          rssinfo["hasSub"] = 0;
        });
        showToast(context, "取消订阅成功");
        eventBus.fire(
            EventAction(EventAction.UNSUB_RSS_SUCCESS_ACTION, widget.rss_id));
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
        "rss_id": widget.rss_id,
        "offset": pageIndex * pageSize,
        "limit": pageSize
      };
      var response =
          await http2.get("/app/user/rss/list", queryParameters: params);
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
    }
  }

  requestRssinfo() async {
    try {
      var params = {"rss_id": widget.rss_id};
      var response =
          await http2.get("/app/user/rss/info", queryParameters: params);
      if (response.data["code"] == 200 && response.data["data"].length > 0) {
        setState(() {
          rssinfo = response.data["data"][0];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    requestRssinfo();
    requestHttp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildSliverAppBar(context, innerBoxIsScrolled) {
    bool hasSub = rssinfo["hasSub"] == 1;
    return SliverAppBar(
        floating: false,
        pinned: true,
        snap: false,
        expandedHeight: 200,
        actions: <Widget>[
          Center(
              child: Container(
            margin: EdgeInsets.only(right: 10.0),
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              value: _indicatorValue,
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2.4,
            ),
          ))
        ],
        flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            collapseMode: CollapseMode.pin,
            title: Text(
              rssinfo["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
            background: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    "assets/timg.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: widget.tag,
                        child: NetworkImageWrapper(
                          rssinfo["logo"],
                          width: 50,
                          height: 50,
                        ),
                      ),
                      Container(height: 10),
                      RaisedButton(
                        textColor: Colors.white,
                        onPressed: () {
                          hasSub ? unsubRss(context) : subRss(context);
                        },
                        child: Text(hasSub ? "取消订阅" : "订阅"),
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  Widget buildItem(context, index) {
    var item = datas[index];
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            item["rss_id"] = widget.rss_id;
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return WebViewPage(item);
            }));
          },
          dense: false,
          title: Text(
            item["title"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Container(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
    await Future.delayed(Duration(seconds: 2), () {});
    await requestHttp();
  }

  Future<void> onLoadMore() async {
    pageIndex++;
    await requestHttp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
      return EasyRefresh(
          key: _easyRefreshKey,
          refreshHeader: ListenerHeader(
            key: _headerKey,
            refreshHeight: _refreshHeight,
            listener: this,
          ),
          refreshFooter: ClassicsFooter(
            key: _footerKey,
            loadText: "加载更多",
            loadReadyText: "松开加载",
            loadingText: "加载中...",
            loadedText: "加载完成",
            noMoreText: "没有更多",
            moreInfo: "上次加载 %T",
            bgColor: Colors.transparent,
            textColor: Colors.black87,
            moreInfoColor: Colors.black54,
            showMore: true,
          ),
          onRefresh: onRefresh,
          loadMore: onLoadMore,
          child: new CustomScrollView(
            // 手动维护semanticChildCount,用于判断是否没有更多数据
            semanticChildCount: datas.length,
            slivers: <Widget>[
              buildSliverAppBar(context, true),
              SliverPadding(padding: EdgeInsets.only(top: 10), sliver: buildBody())
            ],
          ));
    }));
  }

  buildBody() {
    if (currentNetwokStatus == NetworkStatus.Success) {
      return SliverFixedExtentList(
          itemExtent: 57,
          delegate: SliverChildBuilderDelegate(
            buildItem,
            childCount: datas.length,
          ));
    } else {
      return SliverFillRemaining(
        child: Center(
          child: NetworkWrapper(
            networkStatus: currentNetwokStatus,
            retryInit: () {},
            child: Text(""),
          ),
        ),
      );
    }
  }

  double _refreshHeight = 100.0;
  double _indicatorValue = 0.0;
  bool _updateIndicatorValue = false;
  @override
  void onRefreshEnd() {
    setState(() {
      _indicatorValue = 0.0;
    });
  }

  @override
  void onRefreshReady() {}

  @override
  void onRefreshRestore() {}

  @override
  void onRefreshStart() {
    _updateIndicatorValue = true;
  }

  @override
  void onRefreshed() {
    setState(() {
      _indicatorValue = 0.99;
    });
  }

  @override
  void onRefreshing() {
    _updateIndicatorValue = false;
    setState(() {
      _indicatorValue = null;
    });
  }

  var ratio = 1.0;

  @override
  void updateHeaderHeight(double newHeight) {
    if (_updateIndicatorValue) {
      double indicatorValue = newHeight / _refreshHeight * ratio;
      setState(() {
        _indicatorValue = indicatorValue < ratio ? indicatorValue : ratio;
      });
    }
  }
}
