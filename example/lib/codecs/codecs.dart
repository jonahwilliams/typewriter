library typewriter.example.codecs;

import 'package:typewriter/typewriter.dart';
import '../person.dart';

import 'dart:convert';

part 'codecs.g.dart';


@Json()
class TestFoo {
  int name;
}