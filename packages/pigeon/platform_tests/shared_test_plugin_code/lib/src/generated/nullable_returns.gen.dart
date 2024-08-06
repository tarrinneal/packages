// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

PlatformException _createConnectionError(String channelName) {
  return PlatformException(
    code: 'channel-error',
    message: 'Unable to establish connection on channel: "$channelName".',
  );
}

List<Object?> wrapResponse(
    {Object? result, PlatformException? error, bool empty = false}) {
  if (empty) {
    return <Object?>[];
  }
  if (error == null) {
    return <Object?>[result];
  }
  return <Object?>[error.code, error.message, error.details];
}

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
}

class NullableReturnHostApi {
  /// Constructor for [NullableReturnHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableReturnHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeon_binaryMessenger = binaryMessenger,
        pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeon_messageChannelSuffix;

  Future<int?> doit() async {
    final String pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableReturnHostApi.doit$pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeon_channel =
        BasicMessageChannel<Object?>(
      pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeon_binaryMessenger,
    );
    final List<Object?>? pigeon_replyList =
        await pigeon_channel.send(null) as List<Object?>?;
    if (pigeon_replyList == null) {
      throw _createConnectionError(pigeon_channelName);
    } else if (pigeon_replyList.length > 1) {
      throw PlatformException(
        code: pigeon_replyList[0]! as String,
        message: pigeon_replyList[1] as String?,
        details: pigeon_replyList[2],
      );
    } else {
      return (pigeon_replyList[0] as int?);
    }
  }
}

abstract class NullableReturnFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  int? doit();

  static void setUp(
    NullableReturnFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.NullableReturnFlutterApi.doit$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeon_channel.setMessageHandler(null);
      } else {
        pigeon_channel.setMessageHandler((Object? message) async {
          try {
            final int? output = api.doit();
            return wrapResponse(result: output);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}

class NullableArgHostApi {
  /// Constructor for [NullableArgHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableArgHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeon_binaryMessenger = binaryMessenger,
        pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeon_messageChannelSuffix;

  Future<int> doit(int? x) async {
    final String pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit$pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeon_channel =
        BasicMessageChannel<Object?>(
      pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeon_binaryMessenger,
    );
    final List<Object?>? pigeon_replyList =
        await pigeon_channel.send(<Object?>[x]) as List<Object?>?;
    if (pigeon_replyList == null) {
      throw _createConnectionError(pigeon_channelName);
    } else if (pigeon_replyList.length > 1) {
      throw PlatformException(
        code: pigeon_replyList[0]! as String,
        message: pigeon_replyList[1] as String?,
        details: pigeon_replyList[2],
      );
    } else if (pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeon_replyList[0] as int?)!;
    }
  }
}

abstract class NullableArgFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  int? doit(int? x);

  static void setUp(
    NullableArgFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.NullableArgFlutterApi.doit$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeon_channel.setMessageHandler(null);
      } else {
        pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.NullableArgFlutterApi.doit was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_x = (args[0] as int?);
          try {
            final int? output = api.doit(arg_x);
            return wrapResponse(result: output);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}

class NullableCollectionReturnHostApi {
  /// Constructor for [NullableCollectionReturnHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableCollectionReturnHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeon_binaryMessenger = binaryMessenger,
        pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeon_messageChannelSuffix;

  Future<List<String?>?> doit() async {
    final String pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionReturnHostApi.doit$pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeon_channel =
        BasicMessageChannel<Object?>(
      pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeon_binaryMessenger,
    );
    final List<Object?>? pigeon_replyList =
        await pigeon_channel.send(null) as List<Object?>?;
    if (pigeon_replyList == null) {
      throw _createConnectionError(pigeon_channelName);
    } else if (pigeon_replyList.length > 1) {
      throw PlatformException(
        code: pigeon_replyList[0]! as String,
        message: pigeon_replyList[1] as String?,
        details: pigeon_replyList[2],
      );
    } else {
      return (pigeon_replyList[0] as List<Object?>?)?.cast<String?>();
    }
  }
}

abstract class NullableCollectionReturnFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  List<String?>? doit();

  static void setUp(
    NullableCollectionReturnFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionReturnFlutterApi.doit$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeon_channel.setMessageHandler(null);
      } else {
        pigeon_channel.setMessageHandler((Object? message) async {
          try {
            final List<String?>? output = api.doit();
            return wrapResponse(result: output);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}

class NullableCollectionArgHostApi {
  /// Constructor for [NullableCollectionArgHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableCollectionArgHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeon_binaryMessenger = binaryMessenger,
        pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeon_messageChannelSuffix;

  Future<List<String?>> doit(List<String?>? x) async {
    final String pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionArgHostApi.doit$pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeon_channel =
        BasicMessageChannel<Object?>(
      pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeon_binaryMessenger,
    );
    final List<Object?>? pigeon_replyList =
        await pigeon_channel.send(<Object?>[x]) as List<Object?>?;
    if (pigeon_replyList == null) {
      throw _createConnectionError(pigeon_channelName);
    } else if (pigeon_replyList.length > 1) {
      throw PlatformException(
        code: pigeon_replyList[0]! as String,
        message: pigeon_replyList[1] as String?,
        details: pigeon_replyList[2],
      );
    } else if (pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeon_replyList[0] as List<Object?>?)!.cast<String?>();
    }
  }
}

abstract class NullableCollectionArgFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  List<String?> doit(List<String?>? x);

  static void setUp(
    NullableCollectionArgFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionArgFlutterApi.doit$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeon_channel.setMessageHandler(null);
      } else {
        pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.NullableCollectionArgFlutterApi.doit was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<String?>? arg_x =
              (args[0] as List<Object?>?)?.cast<String?>();
          try {
            final List<String?> output = api.doit(arg_x);
            return wrapResponse(result: output);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}
