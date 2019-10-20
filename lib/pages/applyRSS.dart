import 'package:flutter/material.dart';
import '../widget/basestate.dart';
import '../widget/loadingButton.dart';
import '../net/http.dart';
import '../utils/toast.dart';

class ApplyRSS extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ApplyRSSState();
  }
}

class ApplyRSSState extends BaseState<ApplyRSS> {
  var form_key = GlobalKey<FormState>();
  String name, url;
  var loadingStatus = LoadingStatus.normal;
  bool isDisableButton = false;

  startApply(context) async {
    try {
      if (form_key.currentState.validate()) {
        form_key.currentState.save();
        if (isDisableButton) return;
        isDisableButton = true;
        setState(() {
          loadingStatus = LoadingStatus.loadding;
        });
        var params = {"name": name, "url": url};
        var response = await http2.post("/app/user/rss/apply", data: params);
        print(response);
        if (response.data["code"] == 200) {
          showToast(context, "申请成功,请耐心等待～");
          form_key.currentState.reset();
        } else {
          showToast(context, "申请失败,请重试~");
        }
      }
    } catch (error) {
      print(error);
      showToast(context, "申请失败,请重试~");
    } finally {
      setState(() {
        loadingStatus = LoadingStatus.normal;
      });
      isDisableButton = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("申请栏目"),
        ),
        body: Builder(builder: (BuildContext context) {
          return Form(
              key: form_key,
              child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          child: TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "请输入网站名称",
                            ),
                            validator: (value) {
                              if (value.length == 0) {
                                return "名称不能为空";
                              }
                            },
                            onSaved: (value) {
                              name = value;
                            },
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "请输入目标网址",
                              ),
                              validator: (value) {
                                if (value.length == 0) {
                                  return "网址不能为空";
                                }
                              },
                              onSaved: (value) {
                                url = value;
                              },
                            )),

                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text("说明:\n提交申请你喜欢的RSS栏目(通常为网站/APP等),开发小哥哥收到你的申请后会尽快进行开发,完成后我们会第一时间邮件通知您~"),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 60, bottom: 60),
                          alignment: Alignment.center,
                          child: LoadingButton(
                            "申请",
                            onPressed: () {
                              startApply(context);
                            },
                            loadingStatus: loadingStatus,
                          ),
                        )
                      ],
                    )
                  ]));
        }));
  }
}
