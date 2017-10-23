//
//  ControlClient.h
//  Android Things Eddystone Beacon
//
//  Created by Gerard de Jong on 2017/10/22.
//  Copyright © 2017 IQ Business. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControlClient : NSObject <NSStreamDelegate> {
    NSInputStream *InputStream;
    NSOutputStream *OutputStream;
    NSData *InputData;
    NSMutableData *OutputData;
}

@property (strong, nonatomic) NSString * host;
@property (nonatomic) int port;
@property (nonatomic) BOOL relay1;
@property (nonatomic) BOOL relay2;

- (ControlClient *) init;
- (ControlClient *) initWithHost:(NSString*)host andPort:(int)port;
- (void)toggleRelay:(int)relay;

@end
