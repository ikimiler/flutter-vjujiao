import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWrapper extends StatelessWidget {
  String url;
  double width, height;
  BoxShape shape;
  NetworkImageWrapper(this.url, {this.width, this.height, this.shape});

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(this.url,
        width: this.width,
        height: this.height,
        fit: BoxFit.cover,
        shape: this.shape,
        cache: true, loadStateChanged: ((ExtendedImageState state) {
      if (state.extendedImageLoadState == LoadState.failed) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),color: Colors.grey),
        );
      }else if(state.extendedImageLoadState == LoadState.loading){
        return Container(
          width: width,
          height: height,
          color: Colors.transparent,
        );
      }
    }));
  }
}
