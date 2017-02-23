import 'package:typewriter/annotations/annotations.dart';
import 'dart:convert';

@Json()
class B {
  List<int> ints;
  List<String> strings;
  List<bool> bools;
  List<double> doubles;
}