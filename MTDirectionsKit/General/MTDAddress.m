#import "MTDAddress.h"

@implementation MTDAddress

@synthesize country = _country;
@synthesize county = _county;
@synthesize postalCode = _postalCode;
@synthesize state = _state;
@synthesize city = _city;
@synthesize street = _street;
@synthesize fullAddress = _fullAddress;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithAddressString:(NSString *)addressString {
    if ((self = [super init])) {
        _fullAddress = [addressString copy];
    }
    
    return self;
}

- (id)initWithCountry:(NSString *)country
               county:(NSString *)county
           postalCode:(NSString *)postalCode
                state:(NSString *)state
                 city:(NSString *)city
               street:(NSString *)street {
    if ((self = [super init])) {
        _country = [country copy];
        _county = [county copy];
        _postalCode = [postalCode copy];
        _state = [state copy];
        _city = [city copy];
        _street = [street copy];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return self.fullAddress;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDAddress
////////////////////////////////////////////////////////////////////////

- (BOOL)isNormalised {
    return self.country.length > 0 && self.city.length > 0 && self.fullAddress.length == 0;
}

- (NSString *)fullAddress {
    return [self descriptionWithAddressFields:
            MTDAddressFieldCountry |
            MTDAddressFieldCounty |
            MTDAddressFieldPostalCode |
            MTDAddressFieldState |
            MTDAddressFieldCity |
            MTDAddressFieldStreet];
}

- (NSString *)descriptionWithAddressFields:(NSUInteger)addressFieldMask {
    if (!self.normalised) {
        return _fullAddress;
    }

    // TODO: Concatenate non-empty fields that are specified in addressFieldMask

    return nil;
}

@end
