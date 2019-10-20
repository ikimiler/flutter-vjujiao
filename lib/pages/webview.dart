import 'package:app/net/http.dart';
import 'package:app/pages/rssdetail.dart';
import 'package:app/pages/uploadError.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';
import '../widget/basestate.dart';
import '../utils/toast.dart';
import '../widget/networkWrapper.dart';

class WebViewPage extends StatefulWidget {
  dynamic item;
  WebViewPage(this.item);

  @override
  State<StatefulWidget> createState() {
    return WebViewPageState();
  }
}

class WebViewPageState extends BaseState<WebViewPage> {
  bool finished = false;
  WebViewController webViewController;

  buildLoading() {
    if (finished) {
      return Container(
        width: 0,
        height: 0,
      );
    } else {
      return LoadingWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(widget.item, webViewController),
        body: Stack(children: <Widget>[
          Positioned(
              child: WebView(
                  initialUrl: widget.item["link"],
                  // debuggingEnabled:true,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    this.webViewController = webViewController;
                  },
                  // javascriptChannels: <JavascriptChannel>[].toSet(),
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith("http://") ||
                        request.url.startsWith("https://")) {
                      return NavigationDecision.navigate;
                    } else {
                      return NavigationDecision.prevent;
                    }
                  },
                  onPageFinished: (String url) {
                    setState(() {
                      finished = true;
                    });
                  })),
          buildLoading()
        ]));
  }
}

class CustomAppbar extends StatefulWidget with PreferredSizeWidget {
  dynamic item;
  WebViewController webViewController;
  CustomAppbar(this.item, this.webViewController);

  @override
  State<StatefulWidget> createState() {
    return CustomAppbarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomAppbarState extends BaseState<CustomAppbar> {
  bool isCollectFlag = false;

  @override
  initState() {
    super.initState();
    isCollect();
  }

  isCollect() async {
    var response = await http2.post("/app/user/rss/collect/isCollect",
        data: {"backup_rss_id": widget.item["backup_rss_id"]});
    if (response.data["code"] == 200) {
      setState(() {
        isCollectFlag = response.data["data"].length > 0 ? true : false;
      });
    }
  }

  addCollect() async {
    try {
      var response = await http2.post("/app/user/rss/collect",
          data: {"backup_rss_id": widget.item["backup_rss_id"]});
      if (response.data["code"] == 200) {
        showToast(context, "收藏成功");
        setState(() {
          isCollectFlag = true;
        });
      } else {
        showToast(context, "收藏失败");
      }
    } catch (e) {
      showToast(context, "收藏失败");
    }
  }

  cancleCollect() async {
    try {
      var response = await http2.delete("/app/user/rss/collect",
          queryParameters: {"backup_rss_id": widget.item["backup_rss_id"]});
      if (response.data["code"] == 200) {
        showToast(context, "取消成功");
        setState(() {
          isCollectFlag = false;
        });
      } else {
        showToast(context, "取消失败");
      }
    } catch (e) {
      showToast(context, "取消失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: new IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => {
          if (widget.webViewController != null)
            {
              widget.webViewController.canGoBack().then((value) {
                if (value) {
                  widget.webViewController.goBack();
                } else {
                  Navigator.pop(context);
                }
              })
            }
          else
            {Navigator.pop(context)}
        },
      ),
      title: Text(widget.item["title"]),
      actions: <Widget>[buildPopumenuButton(context)],
    );
  }

  buildPopumenuButton(cxt) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return <PopupMenuItem<String>>[
          PopupMenuItem(
            value: "goin",
            child: Text("进入栏目"),
          ),
          PopupMenuItem(
            value: "collect",
            child: Text(isCollectFlag ? "取消收藏" : "添加收藏"),
          ),
          PopupMenuItem(
            value: "share",
            child: Text("好友分享"),
          ),
          PopupMenuItem(
            value: "copy",
            child: Text("复制链接"),
          ),
          PopupMenuItem(
            value: "uploadError",
            child: Text("报告错误"),
          ),
        ];
      },
      onSelected: (value) {
        if (value == "copy") {
          Clipboard.setData(ClipboardData(text: widget.item["link"]));
          showToast(cxt, "复制成功~");
        } else if (value == "share") {
          Share.share(
              '${widget.item["title"]} ${widget.item["link"]} 分享自[V聚焦]');
        } else if (value == "collect") {
          isCollectFlag ? cancleCollect() : addCollect();
        } else if (value == "uploadError") {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return UploadError(widget.item["rss_id"]);
          }));
        } else if (value == "goin") {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return RssDetail(widget.item["rss_id"]);
          }));
        }
      },
    );
  }
}
