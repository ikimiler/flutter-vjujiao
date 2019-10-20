import "package:flutter/material.dart";
import '../widget/loadingButton.dart';
import '../utils/toast.dart';
import '../net/http.dart';
import '../widget/basestate.dart';
import '../utils/tools.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterState();
  }
}

class RegisterState extends BaseState<Register> {
  final form_key = GlobalKey<FormState>();

  String email, password, confirmPassword, intro, name;
  String sexStr = "男";
  bool passwordHidden = true, confirmPasswordHidden = true;
  LoadingStatus loadingStatus = LoadingStatus.normal;
  var image;
  bool isDisableButton = false;

  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  register(context) async {
    try {
      if (form_key.currentState.validate()) {
        form_key.currentState.save();
        if (isDisableButton) return;
        isDisableButton = true;
        setState(() {
          loadingStatus = LoadingStatus.loadding;
        });
        //注册用户
        var params = {
          "email": email,
          "password": password,
          "sex": sexStr == "男" ? 1 : 0,
          "name": name,
          "avatar_url": "",
          "intro": "",
        };
        var userResponse = await http2.post("/app/user/register", data: params);
        if (userResponse.data["code"] == 200) {
          showToast(context, "注册成功");
          form_key.currentState.reset();
        } else {
          showToast(context, userResponse.data["message"]);
        }
      }
    } catch (error) {
      print(error);
      showToast(context, "注册失败,请重试~");
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
          title: Text("注册"),
        ),
        body: Builder(builder: (BuildContext context) {
          return Form(
            key: form_key,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "请输入昵称",
                    suffixIcon: Icon(Icons.person,
                        color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return "昵称不能为空";
                    }
                  },
                  onSaved: (value) {
                    name = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "请输入邮箱",
                    suffixIcon: Icon(Icons.email,
                        color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return "邮箱不能为空";
                    } else if (!isEmail(value)) {
                      return "请输入合法的邮箱";
                    }
                  },
                  onSaved: (value) {
                    email = value;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: passwordHidden,
                  decoration: InputDecoration(
                    labelText: "请输入密码",
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: passwordHidden
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordHidden = !passwordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return "密码不能为空";
                    } else if (value != confirmPasswordController.text) {
                      return "两次输入的密码不一致";
                    }
                  },
                  onSaved: (value) {
                    password = value;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: confirmPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "请再次输入密码",
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: confirmPasswordHidden
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          confirmPasswordHidden = !confirmPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return "密码不能为空";
                    } else if (value != passwordController.text) {
                      return "两次输入的密码不一致";
                    }
                  },
                  onSaved: (value) {
                    confirmPassword = value;
                  },
                ),
                Container(
                    margin: EdgeInsets.only(top: 60, bottom: 60),
                    child: Center(
                      child: LoadingButton(
                        "注册",
                        onPressed: () {
                          register(context);
                        },
                        loadingStatus: loadingStatus,
                      ),
                    )),
              ],
            ),
          );
        }));
  }
}
