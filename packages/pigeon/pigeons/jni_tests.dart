// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(useJni: true),
  kotlinOptions: KotlinOptions(useJni: true),
))
//
@HostApi()
abstract class JniMessageApi {
  String search(String request);
  @async
  String thinkBeforeAnswering();
}
