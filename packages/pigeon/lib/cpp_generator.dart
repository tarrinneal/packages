// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show Error;

/// General comment opening token.
const String _commentPrefix = '//';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

/// The default serializer for Flutter.
const String _defaultCodecSerializer = 'flutter::StandardCodecSerializer';

/// Options that control how C++ code will be generated.
class CppOptions {
  /// Creates a [CppOptions] object
  const CppOptions({
    this.headerIncludePath,
    this.namespace,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// The namespace where the generated class will live.
  final String? namespace;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [CppOptions] from a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  static CppOptions fromMap(Map<String, Object> map) {
    return CppOptions(
      headerIncludePath: map['header'] as String?,
      namespace: map['namespace'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['cppHeaderOut'] as String?,
    );
  }

  /// Converts a [CppOptions] to a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
      if (namespace != null) 'namespace': namespace!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [CppOptions].
  CppOptions merge(CppOptions options) {
    return CppOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Cpp code generation.
class CppGenerator extends Generator<OutputFileOptions<CppOptions>> {
  /// Instantiates a Cpp Generator.
  CppGenerator();

  /// Generates Cpp header files with specified [CppOptions]
  @override
  void generate(OutputFileOptions<CppOptions> generatorOptions, Root root,
      StringSink sink) {
    assert(generatorOptions.fileType == FileType.header ||
        generatorOptions.fileType == FileType.source);

    final Indent indent = Indent(sink);
    writeFilePrologue(generatorOptions, root, sink, indent);
    writeFileImports(generatorOptions, root, sink, indent);

    for (final Enum anEnum in root.enums) {
      writeEnum(generatorOptions, root, sink, indent, anEnum);
    }

    indent.addln('');
    if (generatorOptions.fileType == FileType.header) {
      _writeErrorOr(indent, friends: root.apis.map((Api api) => api.name));
    }
    for (final Class klass in root.classes) {
      writeDataClass(generatorOptions, root, sink, indent, klass);
    }

    for (final Api api in root.apis) {
      if (getCodecClasses(api, root).isNotEmpty) {
        _writeCodec(generatorOptions, root, sink, indent, api);
        indent.addln('');
      }
      if (api.location == ApiLocation.host) {
        writeHostApi(generatorOptions, root, sink, indent, api);
      } else if (api.location == ApiLocation.flutter) {
        writeFlutterApi(generatorOptions, root, sink, indent, api);
      }
    }

    if (generatorOptions.fileType == FileType.header) {
      if (generatorOptions.languageOptions.namespace != null) {
        indent.writeln(
            '}  // namespace ${generatorOptions.languageOptions.namespace}');
      }
      final String guardName = _getGuardName(
          generatorOptions.languageOptions.headerIncludePath,
          generatorOptions.languageOptions.namespace);
      indent.writeln('#endif  // $guardName');
    } else {
      if (generatorOptions.languageOptions.namespace != null) {
        indent.writeln(
            '}  // namespace ${generatorOptions.languageOptions.namespace}');
      }
    }
  }

  @override
  void writeFilePrologue(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    final FileType fileType = generatorOptions.fileType;
    if (fileType == FileType.header) {
      _writeCppHeaderPrologue(generatorOptions, root, sink, indent);
    } else {
      _writeCppSourcePrologue(generatorOptions, root, sink, indent);
    }
  }

  @override
  void writeFileImports(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    final FileType fileType = generatorOptions.fileType;
    if (fileType == FileType.header) {
      _writeCppHeaderImports(generatorOptions, root, sink, indent);
    } else {
      _writeCppSourceImports(generatorOptions, root, sink, indent);
    }
  }

  @override
  void writeEnum(OutputFileOptions<CppOptions> generatorOptions, Root root,
      StringSink sink, Indent indent, Enum anEnum) {
    final FileType fileType = generatorOptions.fileType;
    if (fileType == FileType.header) {
      _writeCppHeaderEnum(generatorOptions, root, sink, indent, anEnum);
    }
  }

  @override
  void writeDataClass(OutputFileOptions<CppOptions> generatorOptions, Root root,
      StringSink sink, Indent indent, Class klass) {
    if (generatorOptions.fileType == FileType.header) {
      // When generating for a Pigeon unit test, add a test fixture friend class to
      // allow unit testing private methods, since testing serialization via public
      // methods is essentially an end-to-end test.
      String? testFixtureClass;
      if (generatorOptions.languageOptions.namespace?.endsWith('_pigeontest') ??
          false) {
        testFixtureClass =
            '${_pascalCaseFromSnakeCase(generatorOptions.languageOptions.namespace!.replaceAll('_pigeontest', ''))}Test';
      }
      _writeCppHeaderDataClass(generatorOptions, root, sink, indent, klass,
          testFriend: testFixtureClass);
    } else {
      _writeCppSourceDataClass(generatorOptions, root, sink, indent, klass);
    }
  }

  @override
  void writeClassEncode(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    assert(generatorOptions.fileType == FileType.source);
    _writeCppSourceClassEncode(generatorOptions.languageOptions, root, sink,
        indent, klass, customClassNames, customEnumNames);
  }

  @override
  void writeClassDecode(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    assert(generatorOptions.fileType == FileType.source);
    _writeCppSourceClassDecode(generatorOptions, root, sink, indent, klass,
        customClassNames, customEnumNames);
  }

  @override
  void writeFlutterApi(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Api api,
  ) {
    if (generatorOptions.fileType == FileType.header) {
      _writeFlutterApiHeader(indent, api, root);
    } else {
      _writeFlutterApiSource(indent, api, root);
    }
  }

  @override
  void writeHostApi(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Api api,
  ) {
    if (generatorOptions.fileType == FileType.header) {
      _writeHostApiHeader(indent, api, root);
    } else {
      _writeHostApiSource(indent, api, root);
    }
  }

  void _writeCodec(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Api api,
  ) {
    if (generatorOptions.fileType == FileType.header) {
      _writeCodecHeader(indent, api, root);
    } else {
      _writeCodecSource(indent, api, root);
    }
  }

  // Header methods.

  /// Writes Cpp header file header to sink.
  void _writeCppHeaderPrologue(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    if (generatorOptions.languageOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.languageOptions.copyrightHeader!,
          linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix $generatedCodeWarning');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.addln('');
  }

  /// Writes Cpp header file imports to sink.
  void _writeCppHeaderImports(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    final String guardName = _getGuardName(
        generatorOptions.languageOptions.headerIncludePath,
        generatorOptions.languageOptions.namespace);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    _writeSystemHeaderIncludeBlock(indent, <String>[
      'flutter/basic_message_channel.h',
      'flutter/binary_messenger.h',
      'flutter/encodable_value.h',
      'flutter/standard_message_codec.h',
    ]);
    indent.addln('');
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'map',
      'string',
      'optional',
    ]);
    indent.addln('');
    if (generatorOptions.languageOptions.namespace != null) {
      indent
          .writeln('namespace ${generatorOptions.languageOptions.namespace} {');
    }
    indent.addln('');
    if (generatorOptions.languageOptions.namespace?.endsWith('_pigeontest') ??
        false) {
      final String testFixtureClass =
          '${_pascalCaseFromSnakeCase(generatorOptions.languageOptions.namespace!.replaceAll('_pigeontest', ''))}Test';
      indent.writeln('class $testFixtureClass;');
    }
    indent.addln('');
    indent.writeln('$_commentPrefix Generated class from Pigeon.');
  }

  /// Writes Cpp header enum to sink.
  void _writeCppHeaderEnum(OutputFileOptions<CppOptions> options, Root root,
      StringSink sink, Indent indent, Enum anEnum) {
    indent.writeln('');
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name} ');
    indent.scoped('{', '};', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '${member.name} = $index${index == anEnum.members.length - 1 ? '' : ','}');
      });
    });
  }

  /// Writes the declaration for the custom class [klass].
  ///
  /// See [_writeCppSourceDataClass] for the corresponding declaration.
  /// This is intended to be added to the header.
  void _writeCppHeaderDataClass(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent, Class klass,
      {String? testFriend}) {
    indent.addln('');

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];

    addDocumentationComments(
        indent, klass.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('class ${klass.name} ');
    indent.scoped('{', '};', () {
      indent.scoped(' public:', '', () {
        indent.writeln('${klass.name}();');
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          addDocumentationComments(
              indent, field.documentationComments, _docCommentSpec);
          final HostDatatype baseDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
          indent.writeln(
              '${_getterReturnType(baseDatatype)} ${_makeGetterName(field)}() const;');
          indent.writeln(
              'void ${_makeSetterName(field)}(${_unownedArgumentType(baseDatatype)} value_arg);');
          if (field.type.isNullable) {
            // Add a second setter that takes the non-nullable version of the
            // argument for convenience, since setting literal values with the
            // pointer version is non-trivial.
            final HostDatatype nonNullType = _nonNullableType(baseDatatype);
            indent.writeln(
                'void ${_makeSetterName(field)}(${_unownedArgumentType(nonNullType)} value_arg);');
          }
          indent.addln('');
        }
      });

      indent.scoped(' private:', '', () {
        indent.writeln('${klass.name}(const flutter::EncodableList& list);');
        indent.writeln('flutter::EncodableList ToEncodableList() const;');
        for (final Class friend in root.classes) {
          if (friend != klass &&
              friend.fields.any(
                  (NamedType element) => element.type.baseName == klass.name)) {
            indent.writeln('friend class ${friend.name};');
          }
        }
        for (final Api api in root.apis) {
          // TODO(gaaclarke): Find a way to be more precise with our
          // friendships.
          indent.writeln('friend class ${api.name};');
          indent.writeln('friend class ${_getCodecSerializerName(api)};');
        }
        if (testFriend != null) {
          indent.writeln('friend class $testFriend;');
        }

        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
          indent.writeln(
              '${_valueType(hostDatatype)} ${_makeInstanceVariableName(field)};');
        }
      });
    }, nestCount: 0);
    indent.writeln('');
  }

  void _writeCodecHeader(Indent indent, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final String codeSerializerName = _getCodecSerializerName(api);
    indent
        .write('class $codeSerializerName : public $_defaultCodecSerializer ');
    indent.scoped('{', '};', () {
      indent.scoped(' public:', '', () {
        indent.writeln('');
        indent.format('''
inline static $codeSerializerName& GetInstance() {
\tstatic $codeSerializerName sInstance;
\treturn sInstance;
}
''');
        indent.writeln('$codeSerializerName();');
      });
      indent.writeScoped(' public:', '', () {
        indent.writeln(
            'void WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const override;');
      });
      indent.writeScoped(' protected:', '', () {
        indent.writeln(
            'flutter::EncodableValue ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const override;');
      });
    }, nestCount: 0);
  }

  void _writeErrorOr(Indent indent,
      {Iterable<String> friends = const <String>[]}) {
    final String friendLines = friends
        .map((String className) => '\tfriend class $className;')
        .join('\n');
    indent.format('''
class FlutterError {
 public:
\texplicit FlutterError(const std::string& code)
\t\t: code_(code) {}
\texplicit FlutterError(const std::string& code, const std::string& message)
\t\t: code_(code), message_(message) {}
\texplicit FlutterError(const std::string& code, const std::string& message, const flutter::EncodableValue& details)
\t\t: code_(code), message_(message), details_(details) {}

\tconst std::string& code() const { return code_; }
\tconst std::string& message() const { return message_; }
\tconst flutter::EncodableValue& details() const { return details_; }

 private:
\tstd::string code_;
\tstd::string message_;
\tflutter::EncodableValue details_;
};

template<class T> class ErrorOr {
 public:
\tErrorOr(const T& rhs) { new(&v_) T(rhs); }
\tErrorOr(const T&& rhs) { v_ = std::move(rhs); }
\tErrorOr(const FlutterError& rhs) {
\t\tnew(&v_) FlutterError(rhs);
\t}
\tErrorOr(const FlutterError&& rhs) { v_ = std::move(rhs); }

\tbool has_error() const { return std::holds_alternative<FlutterError>(v_); }
\tconst T& value() const { return std::get<T>(v_); };
\tconst FlutterError& error() const { return std::get<FlutterError>(v_); };

 private:
$friendLines
\tErrorOr() = default;
\tT TakeValue() && { return std::get<T>(std::move(v_)); }

\tstd::variant<T, FlutterError> v_;
};
''');
  }

  void _writeHostApiHeader(Indent indent, Api api, Root root) {
    assert(api.location == ApiLocation.host);

    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.scoped('{', '};', () {
      indent.scoped(' public:', '', () {
        indent.writeln('${api.name}(const ${api.name}&) = delete;');
        indent.writeln('${api.name}& operator=(const ${api.name}&) = delete;');
        indent.writeln('virtual ~${api.name}() { };');
        for (final Method method in api.methods) {
          final HostDatatype returnType = getHostDatatype(
              method.returnType,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
          final String returnTypeName = _apiReturnType(returnType);

          final List<String> argSignature = <String>[];
          if (method.arguments.isNotEmpty) {
            final Iterable<String> argTypes =
                method.arguments.map((NamedType arg) {
              final HostDatatype hostType = getFieldHostDatatype(
                  arg,
                  root.classes,
                  root.enums,
                  (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
              return _hostApiArgumentType(hostType);
            });
            final Iterable<String> argNames =
                method.arguments.map((NamedType e) => _makeVariableName(e));
            argSignature.addAll(
                map2(argTypes, argNames, (String argType, String argName) {
              return '$argType $argName';
            }));
          }

          addDocumentationComments(
              indent, method.documentationComments, _docCommentSpec);

          if (method.isAsynchronous) {
            argSignature
                .add('std::function<void($returnTypeName reply)> result');
            indent.writeln(
                'virtual void ${_makeMethodName(method)}(${argSignature.join(', ')}) = 0;');
          } else {
            indent.writeln(
                'virtual $returnTypeName ${_makeMethodName(method)}(${argSignature.join(', ')}) = 0;');
          }
        }
        indent.addln('');
        indent.writeln('$_commentPrefix The codec used by ${api.name}.');
        indent
            .writeln('static const flutter::StandardMessageCodec& GetCodec();');
        indent.writeln(
            '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
        indent.writeln(
            'static void SetUp(flutter::BinaryMessenger* binary_messenger, ${api.name}* api);');
        indent.writeln(
            'static flutter::EncodableList WrapError(std::string_view error_message);');
        indent.writeln(
            'static flutter::EncodableList WrapError(const FlutterError& error);');
      });
      indent.scoped(' protected:', '', () {
        indent.writeln('${api.name}() = default;');
      });
    }, nestCount: 0);
  }

  void _writeFlutterApiHeader(Indent indent, Api api, Root root) {
    assert(api.location == ApiLocation.flutter);

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from C++.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.scoped('{', '};', () {
      indent.scoped(' private:', '', () {
        indent.writeln('flutter::BinaryMessenger* binary_messenger_;');
      });
      indent.scoped(' public:', '', () {
        indent
            .write('${api.name}(flutter::BinaryMessenger* binary_messenger);');
        indent.writeln('');
        indent
            .writeln('static const flutter::StandardMessageCodec& GetCodec();');
        for (final Method func in api.methods) {
          final String returnType = func.returnType.isVoid
              ? 'void'
              : _nullSafeCppTypeForDartType(func.returnType);
          final String callback = 'std::function<void($returnType)>&& callback';
          addDocumentationComments(
              indent, func.documentationComments, _docCommentSpec);
          if (func.arguments.isEmpty) {
            indent.writeln('void ${func.name}($callback);');
          } else {
            final Iterable<String> argTypes = func.arguments
                .map((NamedType e) => _nullSafeCppTypeForDartType(e.type));
            final Iterable<String> argNames =
                indexMap(func.arguments, _getSafeArgumentName);
            final String argsSignature =
                map2(argTypes, argNames, (String x, String y) => '$x $y')
                    .join(', ');
            indent.writeln('void ${func.name}($argsSignature, $callback);');
          }
        }
      });
    }, nestCount: 0);
    indent.writeln('');
  }

  // Source methods.

  /// Writes Cpp source file header to sink.
  void _writeCppSourcePrologue(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    if (generatorOptions.languageOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.languageOptions.copyrightHeader!,
          linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix $generatedCodeWarning');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.addln('');
    indent.addln('#undef _HAS_EXCEPTIONS');
    indent.addln('');
  }

  /// Writes Cpp source file imports to sink.
  void _writeCppSourceImports(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent) {
    indent.writeln(
        '#include "${generatorOptions.languageOptions.headerIncludePath}"');
    indent.addln('');
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'flutter/basic_message_channel.h',
      'flutter/binary_messenger.h',
      'flutter/encodable_value.h',
      'flutter/standard_message_codec.h',
    ]);
    indent.addln('');
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'map',
      'string',
      'optional',
    ]);
    indent.addln('');

    if (generatorOptions.languageOptions.namespace != null) {
      indent
          .writeln('namespace ${generatorOptions.languageOptions.namespace} {');
    }
  }

  void _writeCppSourceClassEncode(
    CppOptions generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    indent.write(
        'flutter::EncodableList ${klass.name}::ToEncodableList() const ');
    indent.scoped('{', '}', () {
      indent.scoped('return flutter::EncodableList{', '};', () {
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));

          final String instanceVariable = _makeInstanceVariableName(field);

          String encodableValue = '';
          if (!hostDatatype.isBuiltin &&
              customClassNames.contains(field.type.baseName)) {
            final String operator = field.type.isNullable ? '->' : '.';
            encodableValue =
                'flutter::EncodableValue($instanceVariable${operator}ToEncodableList())';
          } else if (!hostDatatype.isBuiltin &&
              customEnumNames.contains(field.type.baseName)) {
            final String nonNullValue = field.type.isNullable
                ? '(*$instanceVariable)'
                : instanceVariable;
            encodableValue = 'flutter::EncodableValue((int)$nonNullValue)';
          } else {
            final String operator = field.type.isNullable ? '*' : '';
            encodableValue =
                'flutter::EncodableValue($operator$instanceVariable)';
          }

          if (field.type.isNullable) {
            encodableValue =
                '$instanceVariable ? $encodableValue : flutter::EncodableValue()';
          }

          indent.writeln('$encodableValue,');
        }
      });
    });
    indent.addln('');
  }

  void _writeCppSourceClassDecode(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    indent.write(
        '${klass.name}::${klass.name}(const flutter::EncodableList& list) ');
    indent.scoped('{', '}', () {
      enumerate(getFieldsInSerializationOrder(klass),
          (int index, final NamedType field) {
        final String instanceVariableName = _makeInstanceVariableName(field);
        final String pointerFieldName =
            '${_pointerPrefix}_${_makeVariableName(field)}';
        final String encodableFieldName =
            '${_encodablePrefix}_${_makeVariableName(field)}';
        indent.writeln('auto& $encodableFieldName = list[$index];');
        if (customEnumNames.contains(field.type.baseName)) {
          indent.writeln(
              'if (const int32_t* $pointerFieldName = std::get_if<int32_t>(&$encodableFieldName))\t$instanceVariableName = (${field.type.baseName})*$pointerFieldName;');
        } else {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
          if (field.type.baseName == 'int') {
            indent.format('''
if (const int32_t* $pointerFieldName = std::get_if<int32_t>(&$encodableFieldName))
\t$instanceVariableName = *$pointerFieldName;
else if (const int64_t* ${pointerFieldName}_64 = std::get_if<int64_t>(&$encodableFieldName))
\t$instanceVariableName = *${pointerFieldName}_64;''');
          } else if (!hostDatatype.isBuiltin &&
              root.classes
                  .map((Class x) => x.name)
                  .contains(field.type.baseName)) {
            indent.write(
                'if (const flutter::EncodableList* $pointerFieldName = std::get_if<flutter::EncodableList>(&$encodableFieldName)) ');
            indent.scoped('{', '}', () {
              indent.writeln(
                  '$instanceVariableName = ${hostDatatype.datatype}(*$pointerFieldName);');
            });
          } else {
            indent.write(
                'if (const ${hostDatatype.datatype}* $pointerFieldName = std::get_if<${hostDatatype.datatype}>(&$encodableFieldName)) ');
            indent.scoped('{', '}', () {
              indent.writeln('$instanceVariableName = *$pointerFieldName;');
            });
          }
        }
      });
    });
    indent.addln('');
  }

  void _writeCppSourceClassField(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent, Class klass, NamedType field) {
    final HostDatatype hostDatatype = getFieldHostDatatype(field, root.classes,
        root.enums, (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
    final String instanceVariableName = _makeInstanceVariableName(field);
    final String qualifiedGetterName =
        '${klass.name}::${_makeGetterName(field)}';
    final String qualifiedSetterName =
        '${klass.name}::${_makeSetterName(field)}';
    final String returnExpression = hostDatatype.isNullable
        ? '$instanceVariableName ? &(*$instanceVariableName) : nullptr'
        : instanceVariableName;

    // Generates the string for a setter treating the type as [type], to allow
    // generating multiple setter variants.
    String makeSetter(HostDatatype type) {
      const String setterArgumentName = 'value_arg';
      final String valueExpression = type.isNullable
          ? '$setterArgumentName ? ${_valueType(type)}(*$setterArgumentName) : std::nullopt'
          : setterArgumentName;
      return 'void $qualifiedSetterName(${_unownedArgumentType(type)} $setterArgumentName) '
          '{ $instanceVariableName = $valueExpression; }';
    }

    indent.writeln(
        '${_getterReturnType(hostDatatype)} $qualifiedGetterName() const '
        '{ return $returnExpression; }');
    indent.writeln(makeSetter(hostDatatype));
    if (hostDatatype.isNullable) {
      // Write the non-nullable variant; see _writeCppHeaderDataClass.
      final HostDatatype nonNullType = _nonNullableType(hostDatatype);
      indent.writeln(makeSetter(nonNullType));
    }

    indent.addln('');
  }

  /// Writes the implementation for the custom class [klass].
  ///
  /// See [_writeCppHeaderDataClass] for the corresponding declaration.
  /// This is intended to be added to the implementation file.
  void _writeCppSourceDataClass(OutputFileOptions<CppOptions> generatorOptions,
      Root root, StringSink sink, Indent indent, Class klass) {
    final Set<String> customClassNames =
        root.classes.map((Class x) => x.name).toSet();
    final Set<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toSet();

    indent.addln('');
    indent.writeln('$_commentPrefix ${klass.name}');
    indent.addln('');

    // Getters and setters.
    for (final NamedType field in getFieldsInSerializationOrder(klass)) {
      _writeCppSourceClassField(
          generatorOptions, root, sink, indent, klass, field);
    }

    // Serialization.
    writeClassEncode(generatorOptions, root, sink, indent, klass,
        customClassNames, customEnumNames);

    // Default constructor.
    indent.writeln('${klass.name}::${klass.name}() {}');
    indent.addln('');

    // Deserialization.
    writeClassDecode(generatorOptions, root, sink, indent, klass,
        customClassNames, customEnumNames);
  }

  void _writeCodecSource(Indent indent, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final String codeSerializerName = _getCodecSerializerName(api);
    indent.writeln('$codeSerializerName::$codeSerializerName() {}');
    indent.write(
        'flutter::EncodableValue $codeSerializerName::ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const ');
    indent.scoped('{', '}', () {
      indent.write('switch (type) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write('case ${customClass.enumeration}:');
          indent.writeScoped('', '', () {
            indent.writeln(
                'return flutter::CustomEncodableValue(${customClass.name}(std::get<flutter::EncodableList>(ReadValue(stream))));');
          });
        }
        indent.write('default:');
        indent.writeScoped('', '', () {
          indent.writeln(
              'return $_defaultCodecSerializer::ReadValueOfType(type, stream);');
        }, addTrailingNewline: false);
      });
    });
    indent.writeln('');
    indent.write(
        'void $codeSerializerName::WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const ');
    indent.writeScoped('{', '}', () {
      indent.write(
          'if (const flutter::CustomEncodableValue* custom_value = std::get_if<flutter::CustomEncodableValue>(&value)) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write(
              'if (custom_value->type() == typeid(${customClass.name})) ');
          indent.scoped('{', '}', () {
            indent.writeln('stream->WriteByte(${customClass.enumeration});');
            indent.writeln(
                'WriteValue(flutter::EncodableValue(std::any_cast<${customClass.name}>(*custom_value).ToEncodableList()), stream);');
            indent.writeln('return;');
          });
        }
      });
      indent.writeln('$_defaultCodecSerializer::WriteValue(value, stream);');
    });
  }

  void _writeHostApiSource(Indent indent, Api api, Root root) {
    assert(api.location == ApiLocation.host);

    final String codeSerializerName = getCodecClasses(api, root).isNotEmpty
        ? _getCodecSerializerName(api)
        : _defaultCodecSerializer;
    indent.format('''
/// The codec used by ${api.name}.
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codeSerializerName::GetInstance());
}
''');
    indent.writeln(
        '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
    indent.write(
        'void ${api.name}::SetUp(flutter::BinaryMessenger* binary_messenger, ${api.name}* api) ');
    indent.scoped('{', '}', () {
      for (final Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        indent.write('');
        indent.scoped('{', '}', () {
          indent.writeln(
              'auto channel = std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(');
          indent.inc();
          indent.inc();
          indent.writeln('binary_messenger, "$channelName", &GetCodec());');
          indent.dec();
          indent.dec();
          indent.write('if (api != nullptr) ');
          indent.scoped('{', '} else {', () {
            indent.write(
                'channel->SetMessageHandler([api](const flutter::EncodableValue& message, const flutter::MessageReply<flutter::EncodableValue>& reply) ');
            indent.scoped('{', '});', () {
              indent.writeln('flutter::EncodableList wrapped;');
              indent.write('try ');
              indent.scoped('{', '}', () {
                final List<String> methodArgument = <String>[];
                if (method.arguments.isNotEmpty) {
                  indent.writeln(
                      'const auto& args = std::get<flutter::EncodableList>(message);');

                  // Writes the code to declare and populate a variable called
                  // [argName] to use as a parameter to an API method call from
                  // an existing EncodablValue variable called [encodableArgName]
                  // which corresponds to [arg] in the API definition.
                  void extractEncodedArgument(
                      String argName,
                      String encodableArgName,
                      NamedType arg,
                      HostDatatype hostType) {
                    if (arg.type.isNullable) {
                      // Nullable arguments are always pointers, with nullptr
                      // corresponding to null.
                      if (hostType.datatype == 'int64_t') {
                        // The EncodableValue will either be an int32_t or an
                        // int64_t depending on the value, but the generated API
                        // requires an int64_t so that it can handle any case.
                        // Create a local variable for the 64-bit value...
                        final String valueVarName = '${argName}_value';
                        indent.writeln(
                            'const int64_t $valueVarName = $encodableArgName.IsNull() ? 0 : $encodableArgName.LongValue();');
                        // ... then declare the arg as a reference to that local.
                        indent.writeln(
                            'const auto* $argName = $encodableArgName.IsNull() ? nullptr : &$valueVarName;');
                      } else if (hostType.datatype ==
                          'flutter::EncodableValue') {
                        // Generic objects just pass the EncodableValue through
                        // directly.
                        indent.writeln(
                            'const auto* $argName = &$encodableArgName;');
                      } else if (hostType.isBuiltin) {
                        indent.writeln(
                            'const auto* $argName = std::get_if<${hostType.datatype}>(&$encodableArgName);');
                      } else {
                        indent.writeln(
                            'const auto* $argName = &(std::any_cast<const ${hostType.datatype}&>(std::get<flutter::CustomEncodableValue>($encodableArgName)));');
                      }
                    } else {
                      // Non-nullable arguments are either passed by value or
                      // reference, but the extraction doesn't need to distinguish
                      // since those are the same at the call site.
                      if (hostType.datatype == 'int64_t') {
                        // The EncodableValue will either be an int32_t or an
                        // int64_t depending on the value, but the generated API
                        // requires an int64_t so that it can handle any case.
                        indent.writeln(
                            'const int64_t $argName = $encodableArgName.LongValue();');
                      } else if (hostType.datatype ==
                          'flutter::EncodableValue') {
                        // Generic objects just pass the EncodableValue through
                        // directly. This creates an alias just to avoid having to
                        // special-case the argName/encodableArgName distinction
                        // at a higher level.
                        indent.writeln(
                            'const auto& $argName = $encodableArgName;');
                      } else if (hostType.isBuiltin) {
                        indent.writeln(
                            'const auto& $argName = std::get<${hostType.datatype}>($encodableArgName);');
                      } else {
                        indent.writeln(
                            'const auto& $argName = std::any_cast<const ${hostType.datatype}&>(std::get<flutter::CustomEncodableValue>($encodableArgName));');
                      }
                    }
                  }

                  enumerate(method.arguments, (int index, NamedType arg) {
                    final HostDatatype hostType = getHostDatatype(
                        arg.type,
                        root.classes,
                        root.enums,
                        (TypeDeclaration x) =>
                            _baseCppTypeForBuiltinDartType(x));
                    final String argName = _getSafeArgumentName(index, arg);

                    final String encodableArgName =
                        '${_encodablePrefix}_$argName';
                    indent.writeln(
                        'const auto& $encodableArgName = args.at($index);');
                    if (!arg.type.isNullable) {
                      indent.write('if ($encodableArgName.IsNull()) ');
                      indent.scoped('{', '}', () {
                        indent.writeln(
                            'reply(flutter::EncodableValue(WrapError("$argName unexpectedly null.")));');
                        indent.writeln('return;');
                      });
                    }
                    extractEncodedArgument(
                        argName, encodableArgName, arg, hostType);
                    methodArgument.add(argName);
                  });
                }

                final HostDatatype returnType = getHostDatatype(
                    method.returnType,
                    root.classes,
                    root.enums,
                    (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
                final String returnTypeName = _apiReturnType(returnType);
                if (method.isAsynchronous) {
                  methodArgument.add(
                    '[&wrapped, &reply]($returnTypeName&& output) {${indent.newline}'
                    '${_wrapResponse(indent, root, '\treply(flutter::EncodableValue(std::move(wrapped)));${indent.newline}', method.returnType)}'
                    '}',
                  );
                }
                final String call =
                    'api->${_makeMethodName(method)}(${methodArgument.join(', ')})';
                if (method.isAsynchronous) {
                  indent.format('$call;');
                } else {
                  indent.writeln('$returnTypeName output = $call;');
                  indent.format(
                      _wrapResponse(indent, root, '', method.returnType));
                }
              });
              indent.write('catch (const std::exception& exception) ');
              indent.scoped('{', '}', () {
                indent.writeln('wrapped = WrapError(exception.what());');
                if (method.isAsynchronous) {
                  indent.writeln(
                      'reply(flutter::EncodableValue(std::move(wrapped)));');
                }
              });
              if (!method.isAsynchronous) {
                indent.writeln(
                    'reply(flutter::EncodableValue(std::move(wrapped)));');
              }
            });
          });
          indent.scoped(null, '}', () {
            indent.writeln('channel->SetMessageHandler(nullptr);');
          });
        });
      }
    });

    indent.addln('');
    indent.format('''
flutter::EncodableList ${api.name}::WrapError(std::string_view error_message) {
\treturn flutter::EncodableList({
\t\tflutter::EncodableValue(std::string(error_message)),
\t\tflutter::EncodableValue("Error"),
\t\tflutter::EncodableValue()
\t});
}
flutter::EncodableList ${api.name}::WrapError(const FlutterError& error) {
\treturn flutter::EncodableList({
\t\tflutter::EncodableValue(error.message()),
\t\tflutter::EncodableValue(error.code()),
\t\terror.details()
\t});
}''');
    indent.addln('');
  }

  String _wrapResponse(
      Indent indent, Root root, String reply, TypeDeclaration returnType) {
    String elseBody = '';
    final String ifCondition;
    final String errorGetter;
    final String prefix = (reply != '') ? '\t' : '';

    const String nullValue = 'flutter::EncodableValue()';
    if (returnType.isVoid) {
      elseBody = '$prefix\twrapped.push_back($nullValue);${indent.newline}';
      ifCondition = 'output.has_value()';
      errorGetter = 'value';
    } else {
      final HostDatatype hostType = getHostDatatype(returnType, root.classes,
          root.enums, (TypeDeclaration x) => _baseCppTypeForBuiltinDartType(x));
      const String extractedValue = 'std::move(output).TakeValue()';
      final String wrapperType = hostType.isBuiltin
          ? 'flutter::EncodableValue'
          : 'flutter::CustomEncodableValue';
      if (returnType.isNullable) {
        // The value is a std::optional, so needs an extra layer of
        // handling.
        elseBody = '''
$prefix\tauto output_optional = $extractedValue;
$prefix\tif (output_optional) {
$prefix\t\twrapped.push_back($wrapperType(std::move(output_optional).value()));
$prefix\t} else {
$prefix\t\twrapped.push_back($nullValue);
$prefix\t}${indent.newline}''';
      } else {
        elseBody =
            '$prefix\twrapped.push_back($wrapperType($extractedValue));${indent.newline}';
      }
      ifCondition = 'output.has_error()';
      errorGetter = 'error';
    }
    return '${prefix}if ($ifCondition) {${indent.newline}'
        '$prefix\twrapped = WrapError(output.$errorGetter());${indent.newline}'
        '$prefix} else {${indent.newline}'
        '$elseBody'
        '$prefix}'
        '$prefix$reply';
  }

  void _writeFlutterApiSource(Indent indent, Api api, Root root) {
    assert(api.location == ApiLocation.flutter);
    indent.writeln(
        '$_commentPrefix Generated class from Pigeon that represents Flutter messages that can be called from C++.');
    indent.write(
        '${api.name}::${api.name}(flutter::BinaryMessenger* binary_messenger) ');
    indent.scoped('{', '}', () {
      indent.writeln('this->binary_messenger_ = binary_messenger;');
    });
    indent.writeln('');
    final String codeSerializerName = getCodecClasses(api, root).isNotEmpty
        ? _getCodecSerializerName(api)
        : _defaultCodecSerializer;
    indent.format('''
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codeSerializerName::GetInstance());
}
''');
    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final String returnType = func.returnType.isVoid
          ? 'void'
          : _nullSafeCppTypeForDartType(func.returnType);
      String sendArgument;
      final String callback = 'std::function<void($returnType)>&& callback';
      if (func.arguments.isEmpty) {
        indent.write('void ${api.name}::${func.name}($callback) ');
        sendArgument = 'flutter::EncodableValue()';
      } else {
        final Iterable<String> argTypes = func.arguments
            .map((NamedType e) => _nullSafeCppTypeForDartType(e.type));
        final Iterable<String> argNames =
            indexMap(func.arguments, _getSafeArgumentName);
        sendArgument =
            'flutter::EncodableList { ${argNames.map((String arg) => 'flutter::CustomEncodableValue($arg)').join(', ')} }';
        final String argsSignature =
            map2(argTypes, argNames, (String x, String y) => '$x $y')
                .join(', ');
        indent.write(
            'void ${api.name}::${func.name}($argsSignature, $callback) ');
      }
      indent.scoped('{', '}', () {
        const String channel = 'channel';
        indent.writeln(
            'auto channel = std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(');
        indent.inc();
        indent.inc();
        indent.writeln('binary_messenger_, "$channelName", &GetCodec());');
        indent.dec();
        indent.dec();
        indent.write(
            '$channel->Send($sendArgument, [callback](const uint8_t* reply, size_t reply_size) ');
        indent.scoped('{', '});', () {
          if (func.returnType.isVoid) {
            indent.writeln('callback();');
          } else {
            indent.writeln(
                'std::unique_ptr<flutter::EncodableValue> decoded_reply = GetCodec().DecodeMessage(reply, reply_size);');
            indent.writeln(
                'flutter::EncodableValue args = *(flutter::EncodableValue*)(decoded_reply.release());');
            const String output = 'output';

            final bool isBuiltin =
                _baseCppTypeForBuiltinDartType(func.returnType) != null;
            final String returnTypeName =
                _baseCppTypeForDartType(func.returnType);
            if (func.returnType.isNullable) {
              indent.writeln('$returnType $output{};');
            } else {
              indent.writeln('$returnTypeName $output{};');
            }
            const String pointerVariable = '${_pointerPrefix}_$output';
            if (func.returnType.baseName == 'int') {
              indent.format('''
if (const int32_t* $pointerVariable = std::get_if<int32_t>(&args))
\t$output = *$pointerVariable;
else if (const int64_t* ${pointerVariable}_64 = std::get_if<int64_t>(&args))
\t$output = *${pointerVariable}_64;''');
            } else if (!isBuiltin) {
              indent.write(
                  'if (const flutter::EncodableList* $pointerVariable = std::get_if<flutter::EncodableList>(&args)) ');
              indent.scoped('{', '}', () {
                indent.writeln('$output = $returnTypeName(*$pointerVariable);');
              });
            } else {
              indent.write(
                  'if (const $returnTypeName* $pointerVariable = std::get_if<$returnTypeName>(&args)) ');
              indent.scoped('{', '}', () {
                indent.writeln('$output = *$pointerVariable;');
              });
            }

            indent.writeln('callback($output);');
          }
        });
      });
    }
  }
}

String _getCodecSerializerName(Api api) => '${api.name}CodecSerializer';

const String _pointerPrefix = 'pointer';
const String _encodablePrefix = 'encodable';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : _makeVariableName(argument);

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}_arg';

/// Returns a non-nullable variant of [type].
HostDatatype _nonNullableType(HostDatatype type) {
  return HostDatatype(
      datatype: type.datatype, isBuiltin: type.isBuiltin, isNullable: false);
}

String _pascalCaseFromCamelCase(String camelCase) =>
    camelCase[0].toUpperCase() + camelCase.substring(1);

String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

String _pascalCaseFromSnakeCase(String snakeCase) {
  final String camelCase = snakeCase.replaceAllMapped(
      RegExp(r'_([a-z])'), (Match m) => m[1]!.toUpperCase());
  return _pascalCaseFromCamelCase(camelCase);
}

String _makeMethodName(Method method) => _pascalCaseFromCamelCase(method.name);

String _makeGetterName(NamedType field) => _snakeCaseFromCamelCase(field.name);

String _makeSetterName(NamedType field) =>
    'set_${_snakeCaseFromCamelCase(field.name)}';

String _makeVariableName(NamedType field) =>
    _snakeCaseFromCamelCase(field.name);

String _makeInstanceVariableName(NamedType field) =>
    '${_makeVariableName(field)}_';

// TODO(stuartmorgan): Remove this in favor of _isPodType once callers have
// all been updated to using HostDatatypes.
bool _isReferenceType(String dataType) {
  switch (dataType) {
    case 'bool':
    case 'int64_t':
    case 'double':
      return false;
    default:
      return true;
  }
}

/// Returns true if [type] corresponds to a plain-old-data type (i.e., one that
/// should generally be passed by value rather than pointer/reference) in C++.
bool _isPodType(HostDatatype type) {
  return !_isReferenceType(type.datatype);
}

String? _baseCppTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> cppTypeForDartTypeMap = <String, String>{
    'void': 'void',
    'bool': 'bool',
    'int': 'int64_t',
    'String': 'std::string',
    'double': 'double',
    'Uint8List': 'std::vector<uint8_t>',
    'Int32List': 'std::vector<int32_t>',
    'Int64List': 'std::vector<int64_t>',
    'Float64List': 'std::vector<double>',
    'Map': 'flutter::EncodableMap',
    'List': 'flutter::EncodableList',
    'Object': 'flutter::EncodableValue',
  };
  if (cppTypeForDartTypeMap.containsKey(type.baseName)) {
    return cppTypeForDartTypeMap[type.baseName];
  } else {
    return null;
  }
}

/// Returns the base C++ type (without pointer, reference, optional, etc.) for
/// the given [type].
String _baseCppTypeForDartType(TypeDeclaration type) {
  return _baseCppTypeForBuiltinDartType(type) ?? type.baseName;
}

/// Returns the C++ type to use in a value context (variable declaration,
/// pass-by-value, etc.) for the given C++ base type.
String _valueType(HostDatatype type) {
  final String baseType = type.datatype;
  return type.isNullable ? 'std::optional<$baseType>' : baseType;
}

/// Returns the C++ type to use in an argument context without ownership
/// transfer for the given base type.
String _unownedArgumentType(HostDatatype type) {
  final bool isString = type.datatype == 'std::string';
  final String baseType = isString ? 'std::string_view' : type.datatype;
  if (isString || _isPodType(type)) {
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  // TODO(stuartmorgan): Consider special-casing `Object?` here, so that there
  // aren't two ways of representing null (nullptr or an isNull EncodableValue).
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for arguments to a host API. This is slightly
/// different from [_unownedArgumentType] since passing `std::string_view*` in
/// to the host API implementation when the actual type is `std::string*` is
/// needlessly complicated, so it uses `std::string` directly.
String _hostApiArgumentType(HostDatatype type) {
  final String baseType = type.datatype;
  if (_isPodType(type)) {
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for the return of a getter for a field of type
/// [type].
String _getterReturnType(HostDatatype type) {
  final String baseType = type.datatype;
  if (_isPodType(type)) {
    // Use pointers rather than optionals even for nullable POD, since the
    // semantics of using them is essentially identical and this makes them
    // consistent with non-POD.
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for the return of an API method retutrning
/// [type].
String _apiReturnType(HostDatatype type) {
  if (type.datatype == 'void') {
    return 'std::optional<FlutterError>';
  }
  String valueType = type.datatype;
  if (type.isNullable) {
    valueType = 'std::optional<$valueType>';
  }
  return 'ErrorOr<$valueType>';
}

// TODO(stuartmorgan): Audit all uses of this and convert them to context-based
// methods like those above. Code still using this method may well have bugs.
String _nullSafeCppTypeForDartType(TypeDeclaration type,
    {bool considerReference = true}) {
  if (type.isNullable) {
    return 'std::optional<${_baseCppTypeForDartType(type)}>';
  } else {
    String typeName = _baseCppTypeForDartType(type);
    if (_isReferenceType(typeName)) {
      if (considerReference) {
        typeName = 'const $typeName&';
      } else {
        typeName = 'std::unique_ptr<$typeName>';
      }
    }
    return typeName;
  }
}

String _getGuardName(String? headerFileName, String? namespace) {
  String guardName = 'PIGEON_';
  if (headerFileName != null) {
    guardName += '${headerFileName.replaceAll('.', '_').toUpperCase()}_';
  }
  if (namespace != null) {
    guardName += '${namespace.toUpperCase()}_';
  }
  return '${guardName}H_';
}

void _writeSystemHeaderIncludeBlock(Indent indent, List<String> headers) {
  headers.sort();
  for (final String header in headers) {
    indent.writeln('#include <$header>');
  }
}

/// Validates an AST to make sure the cpp generator supports everything.
List<Error> validateCpp(CppOptions options, Root root) {
  final List<Error> result = <Error>[];
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      for (final NamedType arg in method.arguments) {
        if (isEnum(root, arg.type)) {
          // TODO(gaaclarke): Add line number and filename.
          result.add(Error(
              message:
                  "Nullable enum types aren't supported in C++ arguments in method:${api.name}.${method.name} argument:(${arg.type.baseName} ${arg.name})."));
        }
      }
    }
  }
  return result;
}
