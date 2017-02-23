import 'package:typewriter/annotations/annotations.dart';
import 'dart:convert';

abstract class F {
  int get z;
}

@Json()
class E implements F{
  int z;
}