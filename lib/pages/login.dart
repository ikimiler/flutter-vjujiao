import 'package:app/pages/home.dart';
import 'package:app/utils/sp.dart';
import 'package:app/utils/tools.dart';
import "package:flutter/material.dart";
import '../widget/loadingButton.dart';
import '../utils/constant.dart';
import '../net/http.dart';
import 'dart:convert';
import '../widget/basestate.dart';
import '../utils/toast.dart';
import './register.dart';
import './resetPassword.dart';
import 'package:flare_flutter/flare_actor.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends BaseState<Login> {
  var form_key = GlobalKey<FormState>();

  String email, password;
  var passwordHidden = true;
  var loadingStatus = LoadingStatus.normal;
  bool isDisableButton = false;
  final animationName = ["idle", "test", "success", "fail"];
  String currentAnimationName = "idle";

  login(context) async {
    try {
      if (form_key.currentState.validate()) {
        form_key.currentState.save();
        if (isDisableButton) return;
        isDisableButton = true;
        setState(() {
          loadingStatus = LoadingStatus.loadding;
          currentAnimationName = "idle";

        });
        var params = {"email": email, "password": password};
        var response = await http2.post("/app/user/login", data: params);
        if (response.data["code"] == 200) {
          await putStr(Constant.USER_INFO, jsonEncode(response.data["data"]));
          await putStr(Constant.TOKEN, response.data["data"]["token"]);
          authorization(token: response.data["data"]["token"]);
          
          setState(() {
            currentAnimationName = "success";
          });
          await Future.delayed(Duration(seconds: 3), () {});
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return MyHomePage();
          }), (route) => route == null);
        } else {
          setState(() {
            currentAnimationName = "fail";
          });
        }
      } else {
        setState(() {
          currentAnimationName = "fail";
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        currentAnimationName = "fail";
      });
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
        backgroundColor: Color.fromRGBO(170, 207, 212, 1),
        body: Form(
          onChanged: () {
            setState(() {
              if (currentAnimationName == "fail") {
                currentAnimationName = "idle";
              } else {
                currentAnimationName = "test";
              }
            });
          },
          key: form_key,
          child: ListView(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 50),
                height: 200,
                child: FlareActor("flrs/teddy.flr",
                    animation: currentAnimationName,
                    fit: BoxFit.contain,
                    callback: (animationName) {}),
              ),
              Card(
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "请输入邮箱",
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
                          }
                        },
                        onSaved: (value) {
                          password = value;
                        },
                      ),
                      Container(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkResponse(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return Register();
                                }));
                              },
                              child: Text("立即注册"),
                            ),
                            InkResponse(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ResetPassword();
                                }));
                              },
                              child: Text("找回密码"),
                            ),
                          ]),
                      Container(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 60),
                alignment: Alignment.center,
                child: LoadingButton(
                  "登陆",
                  onPressed: () {
                    login(context);
                  },
                  loadingStatus: loadingStatus,
                ),
              )
            ],
          ),
        ));
  }
}
