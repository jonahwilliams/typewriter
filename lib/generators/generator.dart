import 'dart:async';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/src/dart_formatter.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:typewriter/generators/generator.dart';

import '../writer/writer.dart';
import '../analysis/analysis.dart';

class TypewriterGenerator extends Generator {
  final AnalysisStrategy strategy;
  final Writer writer;

  const TypewriterGenerator(this.writer, this.strategy);

  Future<String> generate(Element element, BuildStep step) async {
    if (element is ClassElement) {
      final description = strategy.analyze(element, element.context);
      return writer.write(description, element.context);
    }
    return null;
  }
}
