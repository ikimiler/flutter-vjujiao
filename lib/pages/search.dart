import 'package:app/pages/applyRSS.dart';
import 'package:app/pages/movewebview.dart';
import 'package:app/pages/rssdetail.dart';
import 'package:app/pages/webview.dart';
import 'package:app/widget/networkImageWrapper.dart';
import 'package:flutter/material.dart';
import '../widget/refreshList.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../net/http.dart';

class Search extends StatefulWidget {
  int type; //1文章 2rss栏目
  Search({this.type = 2});

  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<Search> {
  List<dynamic> datas = [];
  int pageIndex = 0, pageSize = 20;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool firstRefresh = false;
  TextEditingController textEditingController = TextEditingController();
  String lastText = "";

  startSearchRSS() async {
    var params = {
      "name": textEditingController.text,
      "offset": pageIndex * pageSize,
      "limit": pageSize
    };
    var response = await http2.post("/app/user/rss/search", data: params);
    if (response.data["code"] == 200) {
      setState(() {
        if (pageIndex == 0) {
          datas = response.data["data"];
        } else {
          datas.addAll(response.data["data"]);
        }
      });
    }
  }

  startSearchArt() async {
    print(textEditingController.text);
    var params = {
      "name": textEditingController.text,
      "offset": pageIndex * pageSize,
      "limit": pageSize
    };
    var response =
        await http2.post("/app/user/rss/backup/search", data: params);
    if (response.data["code"] == 200) {
      setState(() {
        if (pageIndex == 0) {
          datas = response.data["data"];
        } else {
          datas.addAll(response.data["data"]);
        }
      });
    }
  }

  Future<void> onRefresh() async {
    pageIndex = 0;
    await widget.type == 1 ? startSearchArt() : startSearchRSS();
  }

  Future<void> onLoadMore() async {
    pageIndex++;
    await widget.type == 1 ? startSearchArt() : startSearchRSS();
  }

  Widget buildItem(context, index) {
    var item = datas[index];
    if (widget.type == 1) {
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
            title: Text(item["title"]),
          ),
          Divider(
            height: 1,
          )
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          ListTile(
            onTap: () async {
              if (item["type"] == 1) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return RssDetail(
                    item["rss_id"],
                    tag: "tag",
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
            leading: NetworkImageWrapper(
              item["logo"],
              width: 25,
              height: 25,
            ),
            title: Text(item["name"]),
          ),
          Divider(
            height: 1,
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        title: TextField(
            autofocus: true,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            controller: textEditingController,
            textInputAction: TextInputAction.search,
            onSubmitted: (String value) {
              if (value.isEmpty || value == lastText) return;
              lastText = value;
              pageIndex = 0;
              widget.type == 1 ? startSearchArt() : startSearchRSS();
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.grey),
            )),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              textEditingController.clear();
            },
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: RefreshList(
          easyRefreshKey: _easyRefreshKey,
          headerKey: _headerKey,
          footerKey: _footerKey,
          firstRefresh: firstRefresh,
          emptyWidget: widget.type == 1 ? buildArtEmpty() : buildRssEmpty(),
          onRefresh: onRefresh,
          onLoadmore: onLoadMore,
          child: ListView.builder(
            itemCount: datas.length,
            itemBuilder: buildItem,
          )),
    );
  }

  buildArtEmpty() {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 200),
        child: Column(
          children: <Widget>[
            Text(
              "在这里你可以搜索你想看的文章哦~",
              style: TextStyle(color: Colors.black),
            )
          ],
        ));
  }

  buildRssEmpty() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: 200),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "没有栏目,可以点击申请哦～",
              style: TextStyle(color: Colors.black),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: RaisedButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return ApplyRSS();
                    }));
                  },
                  child: Text(
                    "申请栏目",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ))
          ]),
    );
  }
}
