//
//  MTDCryptoTest.m
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 15.08.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDCryptoTest.h"

@implementation MTDCryptoTest

- (void)testBase64 {

}

- (void)testGoogleBusiness {
    MTDDirectionsRequestGoogle *request = [[MTDDirectionsRequestGoogle alloc] init];
    [MTDDirectionsRequestGoogle registerBusinessWithClientId:@"clientID"
                                            cryptographicKey:@"vNIXE0xscrmjlyV-12Nj_BvUPaw="];

    NSString *address = [request preparedAddress:@"http://maps.googleapis.com/maps/api/geocode/json?address=New+York&sensor=false&client=clientID"];

    STAssertEqualObjects(address, @"http://maps.googleapis.com/maps/api/geocode/json?address=New+York&sensor=false&client=clientID&signature=KrU1TzVQM7Ur0i8i7K3huiw3MsA=", @"Error preparing URL for Google Maps for Business");
}

- (void)testGoogleBusiness2 {
    MTDDirectionsRequestGoogle *request = [[MTDDirectionsRequestGoogle alloc] init];
    [MTDDirectionsRequestGoogle registerBusinessWithClientId:@"clientID"
                                            cryptographicKey:@"vNIXE0xscrmjlyV-12Nj_BvUPaw="];

    NSString *address = [request preparedAddress:@"http://maps.googleapis.com/maps/api/directions/xml?destination=Wien&client=clientID&mode=driving&alternatives=true&sensor=true&origin=Guessing%2C%20oesterreich"];

    STAssertEqualObjects(address, @"http://maps.googleapis.com/maps/api/directions/xml?destination=Wien&client=clientID&mode=driving&alternatives=true&sensor=true&origin=Guessing%2C%20oesterreich&signature=5ezQOnZlmv21xEpuCCL8i5fLoJc=", @"Error preparing URL for Google Maps for Business");
}

@end
