import 'package:dio/dio.dart';
import '../utils/eventbus.dart';

BaseOptions options2 = new BaseOptions(
  // baseUrl: "http://10.1.1.217:3000",
  // baseUrl: "http://192.168.0.204:3000",
  baseUrl: "http://47.93.205.239",
  connectTimeout: 1000 * 60,
  receiveTimeout: 1000 * 60,
);

Dio http2 = new Dio(options2);

authorization({token = ""}) {
  http2.interceptors.clear();
  http2.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
    options.headers["authorization"] = 'Bearer $token';
    // 在请求被发送之前做一些事情
    return options; //continue
    // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
    // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
    //
    // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
    // 这样请求将被中止并触发异常，上层catchError会被调用。
  }, onResponse: (Response response) {
    // 在返回响应数据之前做一些预处理
    return response; // continue
  }, onError: (DioError e) {
    if (e != null && e.response != null && e.response.statusCode == 401) {
      eventBus.fire(
          EventAction(EventAction.INVALIDATE_TOKEN_ACTION, ""));
    }
    // 当请求失败时做一些预处理
    return e; //continue
  }));
}
