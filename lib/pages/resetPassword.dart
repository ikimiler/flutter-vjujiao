import 'package:app/utils/sp.dart';
import "package:flutter/material.dart";
import '../widget/loadingButton.dart';
import '../net/http.dart';
import '../utils/constant.dart';
import '../utils/toast.dart';
import '../utils/tools.dart';
import '../widget/basestate.dart';
import './login.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({this.email = ""});

  @override
  State<StatefulWidget> createState() {
    return ResetPasswordState();
  }
}

class ResetPasswordState extends BaseState<ResetPassword> {
  final form_key = GlobalKey<FormState>();

  String email, code, password, confirmPassword;
  var passwordHidden = true, confirmPasswordHidden = true;
  var loadingStatus = LoadingStatus.normal;
  var sendButtonLoadingStatus = LoadingStatus.normal;
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var emailController;
  bool isDisableEmailButton = false;
  bool isDisableResetButton = false;

  @override
  initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }

  resetPassword(context) async {
    try {
      if (form_key.currentState.validate()) {
        form_key.currentState.save();
        if (isDisableResetButton) return;
        isDisableResetButton = true;
        setState(() {
          loadingStatus = LoadingStatus.loadding;
        });
        var params = {
          "email": email,
          "code": code,
          "password": password,
          "confirmPassword": confirmPassword,
        };
        var response =
            await http2.post("/app/user/resetPassword", data: params);
        if (response.data["code"] == 200) {
          showToast(context, "密码重置成功,请重新登录");
          form_key.currentState.reset();
          if (widget.email.length > 0) {
            authorization();
            await putStr(Constant.TOKEN, "");
            await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (BuildContext context) {
              return Login();
            }), (router) => false);
          }
        } else {
          showToast(context, response.data["message"]);
        }
      }
    } catch (error) {
      showToast(context, "密码重置失败,请重试~");
    } finally {
      setState(() {
        loadingStatus = LoadingStatus.normal;
      });
      isDisableResetButton = false;
    }
  }

  sendEmailCode(context) async {
    try {
      if (emailController.text.length > 0 && isEmail(emailController.text)) {
        if (isDisableEmailButton) return;
        isDisableEmailButton = true;
        setState(() {
          sendButtonLoadingStatus = LoadingStatus.loadding;
        });
        var params = {"email": emailController.text};
        var response =
            await http2.post("/app/user/sendEmailCode", data: params);
        if (response.data["code"] == 200) {
          showToast(context, "安全码发送成功,请到邮箱查看");
        } else {
          showToast(context, response.data["message"]);
        }
      } else {
        showToast(context, "请输入合法的邮箱");
      }
    } catch (error) {
      print(error);
      showToast(context, "出现错误,请重试~");
    } finally {
      setState(() {
        sendButtonLoadingStatus = LoadingStatus.normal;
      });
      isDisableEmailButton = false;
    }
  }

  @override
  Widget build(BuildContext context2) {
    return Scaffold(
      appBar: AppBar(
        title: Text("重设密码"),
      ),
      body: Builder(builder: (BuildContext context) {
        return Form(
            key: form_key,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: TextFormField(
                          controller: emailController,
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
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                obscureText: passwordHidden,
                                decoration: InputDecoration(
                                  labelText: "请输入安全码",
                                ),
                                validator: (value) {
                                  if (value.length == 0) {
                                    return "安全码不能为空";
                                  }
                                },
                                onSaved: (value) {
                                  code = value;
                                },
                              )),
                          Positioned(
                            right: 0,
                            child: RaisedButton(
                              shape: StadiumBorder(),
                              onPressed: () {
                                sendEmailCode(context);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Offstage(
                                    offstage: sendButtonLoadingStatus !=
                                        LoadingStatus.loadding,
                                    child: SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white)),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Text(
                                    "发送安全码",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: passwordHidden,
                        decoration: InputDecoration(
                          labelText: "请输入密码",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_red_eye,
                                color: passwordHidden
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor),
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
                        alignment: Alignment.center,
                        child: LoadingButton(
                          "重设密码",
                          onPressed: () {
                            resetPassword(context);
                          },
                          loadingStatus: loadingStatus,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ));
      }),
    );
  }
}
