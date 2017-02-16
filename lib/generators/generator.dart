import 'dart:async';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import '../writer/writer.dart';
import '../analysis/analysis.dart';

class TypewriterGenerator extends Generator {
  final AnalysisStrategy strategy;
  final Writer writer;

  const TypewriterGenerator(this.writer, this.strategy);

  Future<String> generate(Element element, _) async {
    if (element is ClassElement) {
      final description = strategy.analyze(element);
      return writer.write(description);
    }
    return null;
  }
}
