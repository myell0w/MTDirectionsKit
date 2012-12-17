#import "MTDAddress.h"

@implementation MTDAddress

@synthesize fullAddress = _fullAddress;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)addressWithAddressString:(NSString *)addressString {
    return [[self alloc] initWithAddressString:addressString];
}

+ (instancetype)addressWithCountry:(NSString *)country
                             state:(NSString *)state
                            county:(NSString *)county
                        postalCode:(NSString *)postalCode
                              city:(NSString *)city
                            street:(NSString *)street {
    return [[self alloc] initWithCountry:country
                                   state:state
                                  county:county
                              postalCode:postalCode
                                    city:city
                                  street:street];
}

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
        NSString *address1 = [self fullAddress];
        NSString *address2 = [object fullAddress];

        return address1 == address2 || [address1 isEqualToString:address2];
    }

    return NO;
}

- (NSUInteger)hash {
    return self.description.hash;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying
////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(__unused NSZone *)zone {
    return self;
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
    // if not normalized this returns _fullAddress
    return [self descriptionWithAddressFields:
            MTDAddressFieldCountry |
            MTDAddressFieldState |
            MTDAddressFieldCounty |
            MTDAddressFieldPostalCode |
            MTDAddressFieldCity |
            MTDAddressFieldStreet];
}

- (NSDictionary *)addressDictionary {
    if (!self.normalised) {
        return nil;
    }

    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionaryWithCapacity:6];

    // The keys represent the values of the according kABPersonAddressXXXKey constants
    // we don't use the constants directly because we don't want to link against AdressBook-Framework
    // for only this reason. While this may theoretically break, it is very unlikely that the values
    // of the constants will change.

    if (self.street != nil) {
        [addressDictionary setObject:self.street forKey:@"Street"]; // kABPersonAddressStreetKey
    }

    if (self.city != nil) {
        [addressDictionary setObject:self.city forKey:@"City"];     // kABPersonAddressCityKey
    }

    if (self.state != nil) {
        [addressDictionary setObject:self.street forKey:@"State"];  // kABPersonAddressStateKey
    }

    if (self.postalCode != nil) {
        [addressDictionary setObject:self.street forKey:@"ZIP"];    // kABPersonAddressZIPKey
    }

    if (self.country != nil) {
        [addressDictionary setObject:self.street forKey:@"Country"]; // kABPersonAddressCountryKey
    }

    // we don't want to return an empty dictionary
    if (addressDictionary.allKeys.count > 0) {
        return addressDictionary;
    } else {
        return nil;
    }
}

- (NSString *)descriptionWithAddressFields:(NSUInteger)addressFieldMask {
    if (!self.normalised) {
        // using direct iVar here on purpose to not get an infinite loop
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
