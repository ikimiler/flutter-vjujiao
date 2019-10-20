import 'package:app/pages/home.dart';
import 'package:app/pages/login.dart';
import 'package:app/utils/sp.dart';
import 'package:flutter/material.dart';
import '../utils/constant.dart';
import '../net/http.dart';

class Splash extends StatefulWidget {
  @override
  State createState() {
    return SplashState();
  }
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      getStr(Constant.TOKEN).then((value) {
        if (value != null && value.length > 0) {
          print("netlog- token = $value");
          authorization(token: value);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) {
            return MyHomePage();
          }));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) {
            return Login();
          }));
        }
      }).catchError((error) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return Login();
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("关注你所关心的",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)));
  }
}
