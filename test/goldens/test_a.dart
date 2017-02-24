library typewriter.testing.test_a;

import 'package:typewriter/typewriter.dart';
import 'dart:convert';

@Json()
class Dog {
  List<String> names;
  double age;
  DateTime birthday;
}
