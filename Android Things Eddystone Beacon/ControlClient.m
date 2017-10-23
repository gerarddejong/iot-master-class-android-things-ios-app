//
//  ControlClient.m
//  Android Things Eddystone Beacon
//
//  Created by Gerard de Jong on 2017/10/22.
//  Copyright © 2017 IQ Business. All rights reserved.
//

#import "ControlClient.h"

@implementation ControlClient

- (ControlClient *) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (ControlClient *) initWithHost:(NSString*)host andPort:(int)port {
    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;
    }
    return self;
}

- (void)updateRelySataus {
    NSString * response = @"";
    NSInteger result;
    uint8_t buffer[24]; // BUFFER_LEN can be any positive integer
    //while((result = [InputStream read:buffer maxLength:1024]) != 0) {
    result = [InputStream read:buffer maxLength:24];
    if(result > 0) {
        InputData = [NSData dataWithBytes:buffer length:24];
        response = [[NSString alloc] initWithData:InputData encoding:NSASCIIStringEncoding];
        NSLog(@"InputData: %@", response);
        
        NSString *trimmedString = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        InputData = [trimmedString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error = nil;
        NSDictionary * relaySatus = [NSJSONSerialization JSONObjectWithData:InputData options:kNilOptions error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            NSLog(@"Relay Satus: %@", relaySatus);
            
            self.relay1 = [[relaySatus objectForKey:@"relay1"] integerValue] == 1 ? YES : NO;
            self.relay2 = [[relaySatus objectForKey:@"relay2"] integerValue] == 1 ? YES : NO;
        }
    } else {
        NSLog(@"TCP Client - Read Error");
    }
}

- (void)toggleRelay:(int)relay {
    [self openConnection];
    
    [self updateRelySataus];
    
    NSString * instruction  = [NSString stringWithFormat:@"{\"relay\":%d}\n\n", relay];
    NSData * data = [[NSData alloc] initWithData:[instruction dataUsingEncoding:NSASCIIStringEncoding]];
    [OutputStream write:[data bytes] maxLength:[data length]];
    
    [self updateRelySataus];
    
    [self closeConnection];
}

- (void)openConnection {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &readStream, &writeStream);
    
    InputStream = (__bridge NSInputStream *)readStream;
    OutputStream = (__bridge NSOutputStream *)writeStream;
    
    [InputStream setDelegate:self];
    [OutputStream setDelegate:self];
    
    [InputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [OutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [InputStream open];
    [OutputStream open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)StreamEvent {
    switch (StreamEvent) {
        case NSStreamEventOpenCompleted:
            NSLog(@"TCP Client - Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == InputStream) {
                uint8_t buffer[1024];
                long len;
                
                while ([InputStream hasBytesAvailable]) {
                    len = [InputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"TCP Client - Server sent: %@", output);
                        }
                        
                        //Send some data (large block where the write may not actually send all we request it to send)
                        long ActualOutputBytes = [OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                        
                        if (ActualOutputBytes >= 1024) {
                            //It was all sent
                            OutputData = nil;
                        }
                        else {
                            //Only partially sent
                            [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];        //Remove sent bytes from the start
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"TCP Client - Can't connect to the host");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"TCP Client - End encountered");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        case NSStreamEventNone:
            NSLog(@"TCP Client - None event");
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"TCP Client - Has space available event");
            if (OutputData != nil) {
                //Send rest of the packet
                long ActualOutputBytes = [OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                
                if (ActualOutputBytes >= [OutputData length]) {
                    //It was all sent
                    OutputData = nil;
                }
                else {
                    //Only partially sent
                    [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];        //Remove sent bytes from the start
                }
            }
            break;
            
        default:
            NSLog(@"TCP Client - Unknown event");
    }
    
}

- (void)closeConnection {
    [InputStream close];
    [OutputStream close];
    
    InputStream = nil;
    OutputStream = nil;
    if (OutputData != nil) {
        OutputData = nil;
    }
}

@end
