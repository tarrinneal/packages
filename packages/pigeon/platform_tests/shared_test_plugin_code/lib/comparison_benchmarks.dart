// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'integration_tests.dart' show FlutterApiTestImplementation;
import 'ni_integration_tests.dart';
import 'ni_test_types.dart' as ni_types;
import 'src/generated/core_tests.gen.dart' as core;
import 'src/generated/ni_tests.gen.dart' as ni;
import 'test_types.dart' as core_types;

/// Runs benchmarks comparing MethodChannel to Native Interop.
void runComparisonBenchmarks() {
  group('Comparison Benchmarks (MethodChannel vs Native Interop)', () {
    final mcApi = core.HostIntegrationCoreApi();
    final ni.NIHostIntegrationCoreApiForNativeInterop? niApi =
        ni.NIHostIntegrationCoreApiForNativeInterop.getInstance();

    core.FlutterIntegrationCoreApi.setUp(FlutterApiTestImplementation());
    final niRegistrar = ni.NIFlutterIntegrationCoreApiRegistrar();
    niRegistrar.register(NIFlutterIntegrationCoreApiImpl());

    testWidgets('Uint8List Echo 1MB Comparison', (WidgetTester _) async {
      const int size = 1024 * 1024;
      final data = Uint8List(size);
      for (var i = 0; i < size; i++) {
        data[i] = i % 256;
      }

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoUint8List(data);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1MB Uint8List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoUint8List(data);
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 1MB Uint8List Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      } else {
        // ignore: avoid_print
        print('NI_BENCHMARK: Native Interop API not available');
      }
    });

    testWidgets('Large Object List 100 Comparison', (WidgetTester _) async {
      final coreList = List<core.AllNullableTypes?>.generate(
        100,
        (_) => core_types.genericAllNullableTypes,
      );
      final niList = List<ni.NIAllNullableTypes?>.generate(
        100,
        (_) => ni_types.recursiveNIAllNullableTypes,
      );

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoClassList(coreList);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 100 Objects List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoClassList(niList);
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 100 Objects List Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      }
    });

    testWidgets('Large Int List 1000 Comparison', (WidgetTester _) async {
      final list = List<int?>.generate(1000, (i) => i);

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoList(list);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Ints List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoIntList(list);
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 1000 Ints List Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      }
    });

    testWidgets('Large Int Map 1000 Comparison', (WidgetTester _) async {
      final map = <int?, int?>{for (var i = 0; i < 1000; i++) i: i};

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.echoIntMap(map);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Ints Map Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        niApi.echoIntMap(map);
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 1000 Ints Map Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      }
    });

    testWidgets('Small String Echo Comparison (x1000)', (WidgetTester _) async {
      const text = 'Hello Pigeon Benchmark!';

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await mcApi.echoString(text);
      }
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Strings Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          niApi.echoString(text);
        }
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 1000 Strings Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      }
    });

    testWidgets('Small Int Echo Comparison (x1000)', (WidgetTester _) async {
      const value = 42;

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await mcApi.echoInt(value);
      }
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Ints Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      if (niApi != null) {
        final niStopwatch = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          niApi.echoInt(value);
        }
        niStopwatch.stop();
        // ignore: avoid_print
        print(
          'NI_BENCHMARK: 1000 Ints Echo took ${niStopwatch.elapsedMilliseconds}ms',
        );
      }
    });

    testWidgets('Flutter String Echo Comparison (x1000)', (
      WidgetTester _,
    ) async {
      const text = 'Hello Pigeon Benchmark!';

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await mcApi.callFlutterEchoString(text);
      }
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Flutter Strings Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        niApi!.callFlutterEchoString(text);
      }
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 1000 Flutter Strings Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Flutter Int Echo Comparison (x1000)', (WidgetTester _) async {
      const value = 42;

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await mcApi.callFlutterEchoInt(value);
      }
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Flutter Ints Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        niApi!.callFlutterEchoInt(value);
      }
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 1000 Flutter Ints Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Flutter Uint8List Echo 1MB Comparison', (
      WidgetTester _,
    ) async {
      const int size = 1024 * 1024;
      final data = Uint8List(size);
      for (var i = 0; i < size; i++) {
        data[i] = i % 256;
      }

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoUint8List(data);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1MB Flutter Uint8List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoUint8List(data);
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 1MB Flutter Uint8List Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Flutter Large Object List 100 Comparison', (
      WidgetTester _,
    ) async {
      final coreList = List<core.AllNullableTypes?>.generate(
        100,
        (_) => core_types.genericAllNullableTypes,
      );
      final niList = List<ni.NIAllNullableTypes?>.generate(
        100,
        (_) => ni_types.recursiveNIAllNullableTypes,
      );

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoClassList(coreList);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 100 Flutter Objects List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoClassList(niList);
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 100 Flutter Objects List Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Flutter Large Int List 1000 Comparison', (
      WidgetTester _,
    ) async {
      final list = List<int?>.generate(1000, (i) => i);

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoList(list);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Flutter Ints List Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoList(list);
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 1000 Flutter Ints List Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Flutter Large Int Map 1000 Comparison', (
      WidgetTester _,
    ) async {
      final map = <int?, int?>{for (var i = 0; i < 1000; i++) i: i};

      // MethodChannel
      final mcStopwatch = Stopwatch()..start();
      await mcApi.callFlutterEchoIntMap(map);
      mcStopwatch.stop();
      // ignore: avoid_print
      print(
        'MC_BENCHMARK: 1000 Flutter Ints Map Echo took ${mcStopwatch.elapsedMilliseconds}ms',
      );

      // Native Interop
      final niStopwatch = Stopwatch()..start();
      niApi!.callFlutterEchoIntMap(map);
      niStopwatch.stop();
      // ignore: avoid_print
      print(
        'NI_BENCHMARK: 1000 Flutter Ints Map Echo took ${niStopwatch.elapsedMilliseconds}ms',
      );
    });
  });
}
