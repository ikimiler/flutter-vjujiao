import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widget/basestate.dart';
import '../widget/networkWrapper.dart';

class MoveWebview extends StatefulWidget {
  String url;
  String title;
  MoveWebview(this.url, this.title);

  @override
  State<StatefulWidget> createState() {
    return MoveWebviewState();
  }
}

class MoveWebviewState extends BaseState<MoveWebview> {
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
        appBar: AppBar(
          title: Text(widget.title),
          leading: new IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => {
              if (webViewController != null)
                {
                  webViewController.canGoBack().then((value) {
                    if (value) {
                      webViewController.goBack();
                    } else {
                      Navigator.pop(context);
                    }
                  }).catchError((error) {
                    Navigator.pop(context);
                  })
                }
              else
                {Navigator.pop(context)}
            },
          ),
        ),
        body: Stack(children: <Widget>[
          Positioned(
              child: WebView(
                  initialUrl: widget.url,
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
                    // return NavigationDecision.navigate;
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
