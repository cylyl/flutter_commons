import 'package:logger/logger.dart' as L;

class Logger extends L.Logger{
  var logger = L.Logger();

  info(String s){
    print(s);
//    logger.i(s);
  }
}

///print current timestamp
int ptime() {
  int t = new DateTime.now().millisecondsSinceEpoch;
  p(t);
  return t;
}

///lazy print
void p(Object object) {
  print(object);
}

///print trace
void ptrace({String msg='tracing'}) {
  try {
    throw Error();
  } catch (e,t) {
    p(msg);
    p(t.toString());
  }
}