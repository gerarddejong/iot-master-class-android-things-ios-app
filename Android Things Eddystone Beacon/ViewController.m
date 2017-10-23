//
//  ViewController.m
//  Android Things Eddystone Beacon
//
//  Created by Gerard de Jong on 2017/10/20.
//  Copyright © 2017 IQ Business. All rights reserved.
//

#import "ViewController.h"
#import "ESSBeaconScanner.h"
#import "ControlClient.h"

@interface ViewController () <ESSBeaconScannerDelegate> {
    ESSBeaconScanner *_scanner;
    ControlClient * controlClient;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    controlClient = [[ControlClient alloc] initWithHost:@"10.0.0.3" andPort:8080];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _scanner = [[ESSBeaconScanner alloc] init];
    _scanner.delegate = self;
    [_scanner startScanning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_scanner stopScanning];
    _scanner = nil;
}

- (void)beaconScanner:(ESSBeaconScanner *)scanner
        didFindBeacon:(id)beaconInfo {
    NSLog(@"Found Beacon!: %@", beaconInfo);
}

- (void)beaconScanner:(ESSBeaconScanner *)scanner didUpdateBeacon:(id)beaconInfo {
    NSLog(@"Updateed Eddystone!: %@", beaconInfo);
}

- (void)beaconScanner:(ESSBeaconScanner *)scanner didFindURL:(NSURL *)url {
    NSLog(@"Detected URL!: %@", url);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.text = @"Detected Eddystone Beacon!";
    });
}

- (IBAction)didPressRelay1Button:(id)sender {
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"Switching Relay 1 status: %@", controlClient.relay1 ? @"ON" : @"OFF");
        [controlClient toggleRelay:controlClient.relay1 ? 0 : 1];
    //});
}

- (IBAction)didPressRelay2Button:(id)sender {
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"Switching Relay 2 status: %@", controlClient.relay2 ? @"ON" : @"OFF");
        [controlClient toggleRelay:controlClient.relay2 ? 0 : 1];
    //});
}

@end
