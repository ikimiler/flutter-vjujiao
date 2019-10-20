import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class EventAction{

  static const SUB_RSS_SUCCESS_ACTION = "sub_rss_success_action";
  static const UNSUB_RSS_SUCCESS_ACTION = "unsub_rss_success_action";
  static const CHANGE_THEME_ACTION = "change_theme_action";
  static const INVALIDATE_TOKEN_ACTION = "invalidate_token_action";

  String action;
  var data;
  EventAction(this.action,this.data);
}