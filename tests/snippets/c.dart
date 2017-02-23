import 'package:typewriter/annotations/annotations.dart';
import 'dart:convert';

@Json()
class C {
  @JsonKey('1111')
  int t1;

  @JsonKey('abcdec')
  String t2;
}