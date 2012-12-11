//
//  MTDAddress.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 This enum can be used to generate a specific string-representation of a normalised address object.
 Each enum value is a flag representing one field of the address.
 */
typedef NS_ENUM(NSUInteger, MTDAddressField) {
    MTDAddressFieldCountry          = 1,
    MTDAddressFieldState            = 1 << 1,
    MTDAddressFieldCounty           = 1 << 2,
    MTDAddressFieldPostalCode       = 1 << 3,
    MTDAddressFieldCity             = 1 << 4,
    MTDAddressFieldStreet           = 1 << 5
};


/**
 MTDAddress represents the human readable address description of a waypoint.
 It can either be initialized and read in a normalized form (separate fields
 for country, county, postalCode etc.) or with a single string. Currently a
 single string doens't get parsed and normalised.
 */
@interface MTDAddress : NSObject <NSCopying>

/******************************************
 @name Address data
 ******************************************/

/** the country of the address or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *country;
/** the county of the address or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *county;
/** the postal code of the address as string or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *postalCode;
/** the state of the address or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *state;
/** the city of the address or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *city;
/** the street name of the address or nil, if this address isn't normalised */
@property (nonatomic, readonly) NSString *street;

/** The full address string, concatenated via "," */
@property (nonatomic, readonly) NSString *fullAddress;
/** Dictionary representation of the address using the address property keys from ABPerson */
@property (nonatomic, readonly) NSDictionary *addressDictionary;

/**
 This flag indicates whether this address is normalised and the
 separate properties for country, county etc. return valid data
 */
@property (nonatomic, readonly, getter = isNormalised) BOOL normalised;


/******************************************
 @name Initializer
 ******************************************/

/**
 This class method is used to create an address from a single string description.
 The resulting address object is not normalized.

 @param addressString a single string-representation of the address
 @return a non-normalized address object
 */
+ (instancetype)addressWithAddressString:(NSString *)addressString;

/**
 This class method is used to create an address object with normalized data.
 The resulting address object is normalised as well.

 @param country the country of the address
 @param state the state of the address
 @param county the county of the address
 @param postalCode the postal code of the address
 @param city the city of the address
 @param street the street of the address
 @return a normalised address object
 */
+ (instancetype)addressWithCountry:(NSString *)country
                             state:(NSString *)state
                            county:(NSString *)county
                        postalCode:(NSString *)postalCode
                              city:(NSString *)city
                            street:(NSString *)street;

/**
 Initializes an address object with a single string. The resulting address object
 is not normalized.

 @param addressString a single string-representation of the address
 @return a non-normalized address object
 @see initWithCountry:state:county:postalCode:city:street:
 */
- (id)initWithAddressString:(NSString *)addressString;

/**
 Initializes an address object with normalized data.
 The resulting address object is normalised as well.

 @param country the country of the address
 @param state the state of the address
 @param county the county of the address
 @param postalCode the postal code of the address
 @param city the city of the address
 @param street the street of the address
 @return a normalised address object
 @see initWithAddressString:
 */
- (id)initWithCountry:(NSString *)country
                state:(NSString *)state
               county:(NSString *)county
           postalCode:(NSString *)postalCode
                 city:(NSString *)city
               street:(NSString *)street;


/******************************************
 @name String representation
 ******************************************/

/**
 On normalised address objects this method can be used to create a description of the
 address only including the specified address fields (via bitmask). Valid address fields are specified
 in the enum MTDAddressField:

 - MTDAddressFieldCountry
 - MTDAddressFieldState
 - MTDAddressFieldCounty
 - MTDAddressFieldPostalCode
 - MTDAddressFieldCity
 - MTDAddressFieldStreet

 On non-normalized string objects this method just returns the fullAddress string.

 @param addressFieldMask a bitmaks including the address fields to include in the description,
 e.g. MTDAddressFieldCountry | MTDAddressFieldCity

 @return a string representation of the address including the specified fields
 */
- (NSString *)descriptionWithAddressFields:(NSUInteger)addressFieldMask;

@end
