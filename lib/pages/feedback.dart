import '../net/http.dart';
import '../widget/loadingButton.dart';
import 'package:flutter/material.dart';
import '../widget/basestate.dart';
import '../utils/toast.dart';

class FeedbackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeedbackPageState();
  }
}

class FeedbackPageState extends BaseState<FeedbackPage> {
  String value = "";
  LoadingStatus loadingStatus = LoadingStatus.normal;
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  sendFeedback(BuildContext context) async {
    if (value.length == 0) {
      showToast(context, "请先输入反馈内容~");
    } else if (value.length < 10) {
      showToast(context, "反馈内容过短,请继续输入~");
    } else {
      try {
        setState(() {
          loadingStatus = LoadingStatus.loadding;
        });
        var response =
            await http2.post("/app/user/addFeedback", data: {"content": value});
        if (response.data["code"] == -1) {
          showToast(context, response.data["message"]);
        } else {
          showToast(context, "反馈成功");
          controller.clear();
          value = "";
        }
      } catch (e) {
        print(e);
        showToast(context, "反馈失败,请重试~");
      } finally {
        setState(() {
          loadingStatus = LoadingStatus.normal;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("意见反馈"),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          children: <Widget>[
            TextField(
              controller: controller,
              onChanged: (value) {
                this.value = value;
              },
              maxLines: 10,
              autofocus: true,
              decoration: InputDecoration(
                  border: InputBorder.none, labelText: "请输入反馈内容"),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 60,top: 30),
              child: Column(
                children: <Widget>[
                  LoadingButton("发送", loadingStatus: loadingStatus,
                      onPressed: () {
                    sendFeedback(context);
                  })
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
