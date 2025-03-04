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

enum ReplyType {
  success,
  error,
}

class NonNullFieldSearchRequest {
  NonNullFieldSearchRequest({
    required this.query,
  });

  String query;

  List<Object?> toList() {
    return <Object?>[
      query,
    ];
  }

  Object encode() {
    return toList();
  }

  static NonNullFieldSearchRequest decode(Object result) {
    result as List<Object?>;
    return NonNullFieldSearchRequest(
      query: result[0]! as String,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! NonNullFieldSearchRequest ||
        other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return query == other.query;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(toList());
}

class ExtraData {
  ExtraData({
    required this.detailA,
    required this.detailB,
  });

  String detailA;

  String detailB;

  List<Object?> toList() {
    return <Object?>[
      detailA,
      detailB,
    ];
  }

  Object encode() {
    return toList();
  }

  static ExtraData decode(Object result) {
    result as List<Object?>;
    return ExtraData(
      detailA: result[0]! as String,
      detailB: result[1]! as String,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! ExtraData || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return detailA == other.detailA && detailB == other.detailB;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(toList());
}

class NonNullFieldSearchReply {
  NonNullFieldSearchReply({
    required this.result,
    required this.error,
    required this.indices,
    required this.extraData,
    required this.type,
  });

  String result;

  String error;

  List<int?> indices;

  ExtraData extraData;

  ReplyType type;

  List<Object?> toList() {
    return <Object?>[
      result,
      error,
      indices,
      extraData,
      type,
    ];
  }

  Object encode() {
    return toList();
  }

  static NonNullFieldSearchReply decode(Object result) {
    result as List<Object?>;
    return NonNullFieldSearchReply(
      result: result[0]! as String,
      error: result[1]! as String,
      indices: (result[2] as List<Object?>?)!.cast<int?>(),
      extraData: result[3]! as ExtraData,
      type: result[4]! as ReplyType,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! NonNullFieldSearchReply || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return result == other.result &&
        error == other.error &&
        _listEquals(indices, other.indices) &&
        extraData == other.extraData &&
        type == other.type;
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
    } else if (value is ReplyType) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is NonNullFieldSearchRequest) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is ExtraData) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else if (value is NonNullFieldSearchReply) {
      buffer.putUint8(132);
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
        return value == null ? null : ReplyType.values[value];
      case 130:
        return NonNullFieldSearchRequest.decode(readValue(buffer)!);
      case 131:
        return ExtraData.decode(readValue(buffer)!);
      case 132:
        return NonNullFieldSearchReply.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class NonNullFieldHostApi {
  /// Constructor for [NonNullFieldHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NonNullFieldHostApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeonVar_binaryMessenger = binaryMessenger,
        pigeonVar_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeonVar_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeonVar_messageChannelSuffix;

  Future<NonNullFieldSearchReply> search(
      NonNullFieldSearchRequest nested) async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.NonNullFieldHostApi.search$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture =
        pigeonVar_channel.send(<Object?>[nested]);
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
      return (pigeonVar_replyList[0] as NonNullFieldSearchReply?)!;
    }
  }
}

abstract class NonNullFieldFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  NonNullFieldSearchReply search(NonNullFieldSearchRequest request);

  static void setUp(
    NonNullFieldFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.NonNullFieldFlutterApi.search$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeonVar_channel.setMessageHandler(null);
      } else {
        pigeonVar_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.NonNullFieldFlutterApi.search was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final NonNullFieldSearchRequest? arg_request =
              (args[0] as NonNullFieldSearchRequest?);
          assert(arg_request != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.NonNullFieldFlutterApi.search was null, expected non-null NonNullFieldSearchRequest.');
          try {
            final NonNullFieldSearchReply output = api.search(arg_request!);
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
