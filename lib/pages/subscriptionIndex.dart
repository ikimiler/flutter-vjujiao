import 'package:app/pages/movewebview.dart';
import 'package:app/pages/search.dart';
import 'package:flutter/material.dart';
import '../net/http.dart';
import '../widget/networkWrapper.dart';
import '../widget/networkImageWrapper.dart';
import './rsslist.dart';
import './rssdetail.dart';
import '../widget/basestate.dart';

class SubscriptionIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubscriptionIndexState();
  }
}

class SubscriptionIndexState extends BaseState<SubscriptionIndex> {
  NetworkStatus currentNetworkStatus = NetworkStatus.Loading;
  List<dynamic> datas = <dynamic>[];
  @override
  void initState() {
    super.initState();
    requestHttp();
  }

  dispose() {
    super.dispose();
  }

  requestHttp() async {
    if (currentNetworkStatus == NetworkStatus.Fail) {
      setState(() {
        currentNetworkStatus = NetworkStatus.Loading;
      });
    }
    try {
      var response = await http2.get("/app/user/rss/recommend");
      if (response.data["code"] == 200) {
        setState(() {
          currentNetworkStatus = NetworkStatus.Success;
          datas = response.data["data"];
        });
      } else {
        setState(() {
          currentNetworkStatus = NetworkStatus.Fail;
        });
      }
    } catch (e) {
      print("请求失败了 $e");
      setState(() {
        currentNetworkStatus = NetworkStatus.Fail;
      });
    }
  }

  Widget buildItem(context, index) {
    var tag = datas[index];
    String name = tag["name"];
    int tag_id = tag["tag_id"];
    List<dynamic> childs = tag["child"];
    return Container(
      padding: EdgeInsets.all(10),
      height: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              InkResponse(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return RssList(name, tag_id);
                  }));
                },
                child: Text("更多"),
              )
            ],
          ),
          Flexible(
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: childs.map((item) {
                  String tagName = '${tag["name"]}rss_image_${item["name"]}';
                  Widget result = GestureDetector(
                    onTap: () {
                      //跳转不同的界面
                      if (item["type"] == 1) {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return RssDetail(item["rss_id"], tag: tagName);
                        }));
                      } else {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return MoveWebview(
                            item["rss_url"],
                            item["name"],
                          );
                        }));
                      }
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.only(right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Hero(
                            tag: tagName,
                            child: NetworkImageWrapper(
                              item["logo"],
                              width: 50,
                              height: 50,
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          Text(
                            item["name"],
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  );
                  return result;
                }).toList()),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("广场"),
        actions: <Widget>[
          IconButton(
            tooltip: "搜索",
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Search();
              }));
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: NetworkWrapper(
        child: ListView.builder(
          itemCount: datas.length,
          itemBuilder: buildItem,
        ),
        retryInit: () {
          requestHttp();
        },
        networkStatus: currentNetworkStatus,
      ),
    );
  }
}

class Item {
  String name;
  String desc;
  int rss_id;
  String group_name;
  int enable;
  String logo;
  String url;

  Item fromJson(Map<String, dynamic> map) {
    name = map["name"];
    desc = map["desc"];
    rss_id = map["rss_id"];
    group_name = map["group_name"];
    enable = map["enable"];
    logo = map["logo"];
    url = map["url"];
    return this;
  }
}
