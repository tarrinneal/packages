import 'dart:io';

void main() {
  final file = File(
    '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/ni_tests.gen.jni.dart',
  );
  var content = file.readAsStringSync();

  var mapRegex = RegExp(
    r'\$o(\??)\.as<(jni\$_\.JMap<[^>]+?>)>\(\s*jni\$_\.JMap\.type\s*,',
    multiLine: true,
  );
  content = content.replaceAllMapped(mapRegex, (match) {
    var op = match.group(1) ?? '';
    var type = match.group(2)!;
    return '\$o' +
        op +
        '.as<' +
        type +
        '>(\n      jni\$_.JMap.type as jni\$_.JType<' +
        type +
        '>,\n      ';
  });

  var listRegex = RegExp(
    r'\$o(\??)\.as<(jni\$_\.JList<[^>]+?>)>\(\s*jni\$_\.JList\.type\s*,',
    multiLine: true,
  );
  content = content.replaceAllMapped(listRegex, (match) {
    var op = match.group(1) ?? '';
    var type = match.group(2)!;
    return '\$o' +
        op +
        '.as<' +
        type +
        '>(\n      jni\$_.JList.type as jni\$_.JType<' +
        type +
        '>,\n      ';
  });

  file.writeAsStringSync(content);
  print('Replaced successfully.');
}
