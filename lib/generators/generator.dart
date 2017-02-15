import 'dart:async';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import '../writer/writer.dart';
import '../analysis/analysis.dart';

class TypewriterGenerator extends Generator {
  static const Writer _defaultWriter = const Writer();
  static const AnalysisStrategy _defaultAnalysis = const SimpleStrategy();

  const TypewriterGenerator();

  Future<String> generate(Element element, _) async {
    if (element is ClassElement) {
      final description = _defaultAnalysis.analyze(element);
      return _defaultWriter.write(description);
    }
    return null;
  }
}
