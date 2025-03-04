// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
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

bool _listEquals(List<Object?>? list1, List<Object?>? list2) {
  if (list1 == list2) {
    return true;
  }
  if (list1 == null || list2 == null) {
    return false;
  }
  if (list1.length != list2.length) {
    return false;
  }
  bool elementsMatch = true;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] is List) {
      elementsMatch =
          _listEquals(list1[i] as List<Object?>?, list2[i] as List<Object?>?);
    } else if (list1[i] is Map) {
      elementsMatch = _mapEquals(list1[i] as Map<Object?, Object?>?,
          list2[i] as Map<Object?, Object?>?);
    } else {
      elementsMatch = list1[i] == list2[i];
    }
    if (!elementsMatch) {
      return false;
    }
  }
  return true;
}

bool _mapEquals(Map<Object?, Object?>? map1, Map<Object?, Object?>? map2) {
  if (map1 == map2) {
    return true;
  }
  if (map1 == null || map2 == null) {
    return false;
  }
  if (map1.length != map2.length) {
    return false;
  }
  bool elementsMatch = true;
  for (final Object? key in map1.keys) {
    if (!map2.containsKey(key)) {
      return false;
    }
    if (map1[key] is List) {
      elementsMatch =
          _listEquals(map1[key] as List<Object?>?, map2[key] as List<Object?>?);
    } else if (map1[key] is Map) {
      elementsMatch = _mapEquals(map1[key] as Map<Object?, Object?>?,
          map2[key] as Map<Object?, Object?>?);
    } else {
      elementsMatch = map1[key] == map2[key];
    }
    if (!elementsMatch) {
      return false;
    }
  }
  return true;
}

enum Code {
  one,
  two,
}

class MessageData {
  MessageData({
    this.name,
    this.description,
    required this.code,
    required this.data,
  });

  String? name;

  String? description;

  Code code;

  Map<String, String> data;

  List<Object?> toList() {
    return <Object?>[
      name,
      description,
      code,
      data,
    ];
  }

  Object encode() {
    return toList();
  }

  static MessageData decode(Object result) {
    result as List<Object?>;
    return MessageData(
      name: result[0] as String?,
      description: result[1] as String?,
      code: result[2]! as Code,
      data: (result[3] as Map<Object?, Object?>?)!.cast<String, String>(),
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! MessageData || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return name == other.name &&
        description == other.description &&
        code == other.code &&
        _mapEquals(data, other.data);
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(toList());
}

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    } else if (value is Code) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is MessageData) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129:
        final int? value = readValue(buffer) as int?;
        return value == null ? null : Code.values[value];
      case 130:
        return MessageData.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class ExampleHostApi {
  /// Constructor for [ExampleHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  ExampleHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeonVar_binaryMessenger = binaryMessenger,
        pigeonVar_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeonVar_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeonVar_messageChannelSuffix;

  Future<String> getHostLanguage() async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.getHostLanguage$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture = pigeonVar_channel.send(null);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as String?)!;
    }
  }

  Future<int> add(int a, int b) async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.add$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture =
        pigeonVar_channel.send(<Object?>[a, b]);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as int?)!;
    }
  }

  Future<bool> sendMessage(MessageData message) async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.sendMessage$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture =
        pigeonVar_channel.send(<Object?>[message]);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as bool?)!;
    }
  }
}

abstract class MessageFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  String flutterMethod(String? aString);

  static void setUp(
    MessageFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_example_package.MessageFlutterApi.flutterMethod$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeonVar_channel.setMessageHandler(null);
      } else {
        pigeonVar_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_example_package.MessageFlutterApi.flutterMethod was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_aString = (args[0] as String?);
          try {
            final String output = api.flutterMethod(arg_aString);
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
