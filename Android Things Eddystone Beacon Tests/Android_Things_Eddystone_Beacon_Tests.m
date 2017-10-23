//
//  Android_Things_Eddystone_Beacon_Tests.m
//  Android Things Eddystone Beacon Tests
//
//  Created by Gerard de Jong on 2017/10/22.
//  Copyright © 2017 IQ Business. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ControlClient.h"

@interface Android_Things_Eddystone_Beacon_Tests : XCTestCase

@end

@implementation Android_Things_Eddystone_Beacon_Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRelayToggle {
    ControlClient * controlClient = [[ControlClient alloc] initWithHost:@"10.0.0.3" andPort:8080];
    [controlClient toggleRelay:1];
}

@end
