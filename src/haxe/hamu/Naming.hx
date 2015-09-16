package hamu;
class Naming {

  public static function processName(sb:StringBuf, s:String):Void {
    var i = 0;
    while (true) {
      var prev = i;
      var found = s.indexOf("_", prev);
      if (found != -1) {
        sb.addSub(s, prev, found - prev);
        sb.add("__");
        i = found + 1;
      }
      else {
        sb.addSub(s, prev);
        break;
      }
    }
  }

}
