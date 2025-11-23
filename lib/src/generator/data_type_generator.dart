import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:willshex_storage/storage.dart';

Builder dataTypeGenerator(BuilderOptions options) {
  return PartBuilder([const DataTypeGenerator()], '.sc.dart');
}

class DataTypeGenerator extends Generator {
  const DataTypeGenerator();

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final result = StringBuffer();
    final dataTypeChecker = TypeChecker.fromRuntime(DataType);

    for (final classElement in library.classes) {
      if (dataTypeChecker.isAssignableFrom(classElement) &&
          !classElement.isAbstract &&
          classElement.name != 'DataType') {
        final className = classElement.name;
        final camelCaseName = StringUtils.camelCase(className);
        final constantName = '${camelCaseName}StorageClass';

        result.writeln(
            'const Class<$className> $constantName = Class("$className", $className.new, $className.string, $className.json);');
        result.writeln();
        result.writeln('extension ${className}Loader on Loader {');
        result.writeln('  LoadType<$className> get $camelCaseName => type<$className>($constantName);');
        result.writeln('}');
        result.writeln();
        result.writeln('extension ${className}Deleter on Deleter {');
        result.writeln('  DeleteType get $camelCaseName => type($constantName);');
        result.writeln('}');
        result.writeln();
        result.writeln('extension ${className}Compactor on Compactor {');
        result.writeln('  Future<void> get $camelCaseName => type($constantName);');
        result.writeln('}');
      }
    }

    return result.toString();
  }
}