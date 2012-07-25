#import "MTDAddress.h"

@implementation MTDAddress

@synthesize fullAddress = _fullAddress;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithAddressString:(NSString *)addressString {
    if ((self = [super init])) {
        _fullAddress = [addressString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return self;
}

- (id)initWithCountry:(NSString *)country
                state:(NSString *)state
               county:(NSString *)county
           postalCode:(NSString *)postalCode
                 city:(NSString *)city
               street:(NSString *)street {
    if ((self = [super init])) {
        _country = [country stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _state = [state stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _county = [county stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _postalCode = [postalCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _city = [city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _street = [street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return self.fullAddress;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MTDAddress class]]) {
        return [[self description] isEqualToString:[object description]];
    }

    return NO;
}

- (NSUInteger)hash {
    return self.description.hash;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDAddress
////////////////////////////////////////////////////////////////////////

- (BOOL)isNormalised {
    // Using direct iVar here on purpose, otherwise we get an infinite loop
    // descriptionWithAddressFields - isNormalised - fullAddress - descriptionWithAddressFields
    return _fullAddress.length == 0;
}

- (NSString *)fullAddress {
    return [self descriptionWithAddressFields:
            MTDAddressFieldCountry |
            MTDAddressFieldState |
            MTDAddressFieldCounty |
            MTDAddressFieldPostalCode |
            MTDAddressFieldCity |
            MTDAddressFieldStreet];
}

- (NSString *)descriptionWithAddressFields:(NSUInteger)addressFieldMask {
    if (!self.normalised) {
        return _fullAddress;
    }

    BOOL includeStreet = (addressFieldMask & MTDAddressFieldStreet) == MTDAddressFieldStreet;
    BOOL includePostalCode = (addressFieldMask & MTDAddressFieldPostalCode) == MTDAddressFieldPostalCode;
    BOOL includeCity = (addressFieldMask & MTDAddressFieldCity) == MTDAddressFieldCity;
    BOOL includeCounty = (addressFieldMask & MTDAddressFieldCounty) == MTDAddressFieldCounty;
    BOOL includeState = (addressFieldMask & MTDAddressFieldState) == MTDAddressFieldState;
    BOOL includeCountry = (addressFieldMask & MTDAddressFieldCountry) == MTDAddressFieldCountry;

    BOOL postalCodeIncluded = includePostalCode && self.postalCode.length > 0;
    NSMutableString *address = [NSMutableString string];

    if (includeStreet && self.street.length > 0) {
        [address appendFormat:@"%@, ", self.street];
    }

    if (postalCodeIncluded) {
        [address appendFormat:@"%@, ", self.postalCode];
    }

    if (includeCity && self.city.length > 0) {
        // we don't want a comma between postal code and street
        if (postalCodeIncluded) {
            NSRange lastCharactersRange = NSMakeRange(address.length-2, 1);
            [address deleteCharactersInRange:lastCharactersRange];
        }

        [address appendFormat:@"%@, ", self.city];
    }

    if (includeCounty && self.county.length > 0) {
        [address appendFormat:@"%@, ", self.county];
    }

    if (includeState && self.state.length > 0) {
        [address appendFormat:@"%@, ", self.state];
    }

    if (includeCountry && self.country.length > 0) {
        [address appendFormat:@"%@, ", self.country];
    }

    // delete last ", "
    if (address.length > 0) {
        NSRange lastCharactersRange = NSMakeRange(address.length-2, 2);

        [address deleteCharactersInRange:lastCharactersRange];
    }

    return [address copy];
}

@end
