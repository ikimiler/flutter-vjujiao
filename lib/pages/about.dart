import 'package:flutter/material.dart';
import '../widget/basestate.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AboutPageState();
  }
}

class AboutPageState extends BaseState<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("关于我们"),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: <Widget>[
                Text(
                  "版权声明:\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    "该应用提供的信息资料、图片及视频等均来源于公开网络,我们不存储任何数据内容,仅提供类似搜索引擎的推荐服务,所有详细信息都跳转到原始网页地址访问,如果侵犯了您的权益,请与我们联系,我们会尽快处理.同时请注意原网站的观点不表示我们也认同,信息内容真实性请自己辨别。\n",
                    style: TextStyle()),
                Text(
                  "联系方式:\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("email: admin@vjujiao.com\n"),
                Text(
                  "微信群:\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("加andmizi,邀请你进群"),
              ]);
        }));
  }
}
