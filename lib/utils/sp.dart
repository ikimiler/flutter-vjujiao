import 'package:shared_preferences/shared_preferences.dart';

Future<void> putStr(key,value)async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  await sp.setString(key, value);
}

Future<String> getStr(key)async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getString(key);
}

Future<void> putInt(key,value)async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  await sp.setInt(key, value);
}

Future<int> getInt(key)async{
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getInt(key);
}

