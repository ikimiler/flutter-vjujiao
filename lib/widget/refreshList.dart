import 'package:app/widget/networkWrapper.dart' as prefix0;
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class RefreshList extends StatelessWidget {
  Widget child;
  OnRefresh onRefresh;
  LoadMore onLoadmore;
  bool firstRefresh;
  Widget emptyWidget;
  RefreshList({
    this.child,
    this.onRefresh,
    this.onLoadmore,
    this.firstRefresh,
    this.emptyWidget,
    this.easyRefreshKey,
    this.headerKey,
    this.footerKey,
  });

  GlobalKey<EasyRefreshState> easyRefreshKey;
  GlobalKey<RefreshHeaderState> headerKey;
  GlobalKey<RefreshFooterState> footerKey;

  Widget buildEmptyWidget(context) {
    var screen = MediaQuery.of(context);
    var height =
        screen.size.height - screen.padding.top - 56 - screen.padding.bottom;
    return Container(
        height: height,
        child: emptyWidget != null ? emptyWidget : prefix0.EmptyWidget());
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      firstRefresh: firstRefresh,
      emptyWidget: emptyWidget != null ? emptyWidget : null,
      key: easyRefreshKey,
      behavior: ScrollOverBehavior(),
      refreshHeader: ClassicsHeader(
        key: headerKey,
        refreshText: "下拉刷新",
        refreshReadyText: "松开刷新",
        refreshingText: "刷新...",
        refreshedText: "刷新完成",
        moreInfo: "上次刷新 %T",
        bgColor: Colors.transparent,
        textColor: Colors.black87,
        moreInfoColor: Colors.black54,
        showMore: true,
      ),
      refreshFooter: ClassicsFooter(
        key: footerKey,
        loadText: "加载更多",
        loadReadyText: "松开加载",
        loadingText: "加载中...",
        loadedText: "加载完成",
        noMoreText: "没有更多",
        moreInfo: "上次加载 %T",
        bgColor: Colors.transparent,
        textColor: Colors.black87,
        moreInfoColor: Colors.black54,
        showMore: true,
      ),
      child: child,
      onRefresh: onRefresh,
      loadMore: onLoadmore,
    );
  }
}
