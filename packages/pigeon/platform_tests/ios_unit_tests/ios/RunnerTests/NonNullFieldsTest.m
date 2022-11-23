
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import "EchoMessenger.h"
#import "NonNullFields.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface NonNullFieldsTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation NonNullFieldsTest

- (void)testMake {
  NonNullFieldSearchRequest *request = [NonNullFieldSearchRequest makeWithQuery:@"hello"];
  XCTAssertEqualObjects(@"hello", request.query);
}

@end
