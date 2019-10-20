import '../net/http.dart';
import '../widget/loadingButton.dart';
import 'package:flutter/material.dart';
import '../widget/basestate.dart';
import '../utils/toast.dart';

class UploadError extends StatefulWidget {
  var rss_id;
  UploadError(this.rss_id);

  @override
  State<StatefulWidget> createState() {
    return UploadErrorState();
  }
}

class UploadErrorState extends BaseState<UploadError> {
  String value = "";
  LoadingStatus loadingStatus = LoadingStatus.normal;
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  uploadError(BuildContext context) async {
    if (value.length == 0) {
      showToast(context, "请先输入错误描述~");
    } else if (value.length < 10) {
      showToast(context, "错误描述过短,请继续输入~");
    } else {
      try {
        setState(() {
          loadingStatus = LoadingStatus.loadding;
        });
        var response = await http2.post("/app/user/rss/error",
            data: {"target_backup_rss_id": widget.rss_id, "content": value});
        if (response.data["code"] == 200) {
          showToast(context, "上报成功");
          controller.clear();
          value = "";
        } else {
          showToast(context, "上报失败");
        }
      } catch (e) {
        showToast(context, "上报失败");
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
        title: Text("上报错误"),
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
                  border: InputBorder.none, labelText: "请输入错误描述"),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 60, top: 30),
              child: Column(
                children: <Widget>[
                  LoadingButton("发送", loadingStatus: loadingStatus,
                      onPressed: () {
                    uploadError(context);
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
