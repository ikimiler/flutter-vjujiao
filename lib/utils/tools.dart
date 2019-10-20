/**
 * 校验邮箱
 */
isEmail(text){
  RegExp reg = new RegExp(r"([a-zA-Z]|[0-9])(\w|\-)+@[a-zA-Z0-9]+\.([a-zA-Z]{2,4})");
  return reg.hasMatch(text);
}