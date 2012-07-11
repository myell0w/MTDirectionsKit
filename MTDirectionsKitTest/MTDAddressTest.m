#import "MTDAddressTest.h"

@implementation MTDAddressTest


- (void)setUp {
    [super setUp];
    
    normalisedAddress = [[MTDAddress alloc] initWithCountry:@"United Kingdom"
                                                      state:@"England"
                                                     county:@"Reading"
                                                 postalCode:@"RG1 1TT"
                                                       city:@"Reading"
                                                     street:nil];

    nonNormalisedAddress = [[MTDAddress alloc] initWithAddressString:@"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich"];
}

- (void)testNormalised {
    STAssertEqualObjects(normalisedAddress.country, @"United Kingdom", @"Country not equal");
    STAssertEqualObjects(normalisedAddress.county, @"Reading", @"County not equal");
    STAssertEqualObjects(normalisedAddress.postalCode, @"RG1 1TT", @"Postal code not equal");
    STAssertEqualObjects(normalisedAddress.state, @"England", @"State not equal");
    STAssertEqualObjects(normalisedAddress.city, @"Reading", @"City not equal");
    STAssertEqualObjects(normalisedAddress.street, nil, @"Street not equal");
}

- (void)testNonNormalised {
    STAssertEqualObjects(nonNormalisedAddress.country, nil, @"Country not equal");
    STAssertEqualObjects(nonNormalisedAddress.county, nil, @"County not equal");
    STAssertEqualObjects(nonNormalisedAddress.postalCode, nil, @"Postal code not equal");
    STAssertEqualObjects(nonNormalisedAddress.state, nil, @"State not equal");
    STAssertEqualObjects(nonNormalisedAddress.city, nil, @"City not equal");
    STAssertEqualObjects(nonNormalisedAddress.street, nil, @"Street not equal");
    STAssertEqualObjects(nonNormalisedAddress.fullAddress, @"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich", @"Full address not equal");
}


- (void)testNormalisedDescription {
    NSString *fullDescription = @"RG1 1TT Reading, Reading, England, United Kingdom";

    STAssertEqualObjects([normalisedAddress description], fullDescription, @"Description not equal");
    STAssertEqualObjects(normalisedAddress.fullAddress, fullDescription, @"Full address not equal");
    STAssertEqualObjects([normalisedAddress descriptionWithAddressFields:MTDAddressFieldCity | MTDAddressFieldStreet | MTDAddressFieldCountry],
                         @"Reading, United Kingdom", @"descriptionWithFields not equal");
} 

- (void)testNonNormalisedDescription {
    STAssertEqualObjects(nonNormalisedAddress.fullAddress, @"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich", @"Full address not equal");
    STAssertEqualObjects(nonNormalisedAddress.description, @"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich", @"Description not equal");
    STAssertEqualObjects([nonNormalisedAddress descriptionWithAddressFields:MTDAddressFieldCity | MTDAddressFieldCounty], @"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich", @"Description with fields not equal");
} 

@end
