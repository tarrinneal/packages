// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// A superclass of generator classes.
///
/// This provides the structure that is common across generators for different languages.
abstract class Generator<T> {
  /// Generates files for specified language with specified [generatorOptions]
  ///
  /// This method, when overridden, should follow a generic structure that is currently:
  /// 1. Create Indent
  /// 2. Write File Headers
  /// 3. Write Imports
  /// 4. Generate File
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink,
  );

  /// Adds specified file headers.
  void writeFilePrologue(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  );

  /// Adds specified imports.
  void writeFileImports(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  );
}
