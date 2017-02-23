import 'package:typewriter/annotations/annotations.dart';
import 'dart:convert';

class X {
  int x;
}

@Json()
class D extends X {
  int y;
}