import 'package:flutter/material.dart';

enum LoadingStatus { normal, loadding }

class LoadingButton extends StatelessWidget {
  final String title;
  final LoadingStatus loadingStatus;
  final Color buttonBackgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double width;
  final double height;

  LoadingButton(
    this.title, {
    this.onPressed,
    this.loadingStatus = LoadingStatus.normal,
    this.buttonBackgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.width = 300,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: RaisedButton(
          onPressed: (){
            if(loadingStatus != LoadingStatus.loadding) onPressed();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Offstage(
                offstage: loadingStatus != LoadingStatus.loadding,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)
                      ),
                ),
              ),
              Container(
                width: loadingStatus != LoadingStatus.loadding ? 0 : 50,
              ),
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ],
          ),
          // color: buttonBackgroundColor,
          // shape: StadiumBorder(),
        ));
  }
}
