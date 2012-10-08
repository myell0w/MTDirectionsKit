#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"
#import "MTDBase64.h"
#import "MTDLocale+Google.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>


#define kMTDGoogleDomain              @"http://maps.googleapis.com"
#define kMTDGoogleBaseAddress         kMTDGoogleDomain @"/maps/api/directions/xml"


static NSString *mtd_clientId = nil;
static NSString *mtd_cryptographicKey = nil;


@implementation MTDDirectionsRequestGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
           options:(NSUInteger)options
        completion:(mtd_parser_block)completion {
    if ((self = [super initWithFrom:from to:to intermediateGoals:intermediateGoals routeType:routeType options:options completion:completion])) {
        [self mtd_setup];
        
        [self setValue:[from descriptionForAPI:[self API]] forParameter:@"origin"];
        [self setValue:[to descriptionForAPI:[self API]] forParameter:@"destination"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeGoogle(routeType) forParameter:@"mode"];


        // set parameter for alternative routes?
        BOOL alternativeRoutes = (self.mtd_options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;
        if (alternativeRoutes) {
            [self setValue:@"true" forParameter:@"alternatives"];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsAPI)API {
    return MTDDirectionsAPIGoogle;
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    if (intermediateGoals.count > 0 && self.routeType != MTDDirectionsRouteTypePedestrianIncludingPublicTransport) {
        BOOL optimizeRoute = (self.mtd_options & MTDDirectionsRequestOptionOptimize) == MTDDirectionsRequestOptionOptimize;
        NSMutableString *parameter = [NSMutableString stringWithString:(optimizeRoute ? @"optimize:true" : @"optimize:false")];
        
        [intermediateGoals enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
            [parameter appendFormat:@"|%@",[obj descriptionForAPI:[self API]]];
        }];
        
        [self setValue:parameter forParameter:@"waypoints"];
    }
}

// Overwritten to compute signature, if a business was registered
// Algorithm is described here: https://developers.google.com/maps/documentation/business/webservices#digital_signatures
// 1. Construct your URL, making sure to include your client and sensor parameters. (=address)
- (NSURL *)preparedURLForAddress:(NSString *)address {
    if (![[self class] isBusinessRegistered]) {
        return [NSURL URLWithString:address];
    }

    // 2. Strip off the domain portion of the request, leaving only the path and the query
    NSString *path = [address stringByReplacingOccurrencesOfString:kMTDGoogleDomain withString:@""];
    NSData *pathData = [path dataUsingEncoding:NSASCIIStringEncoding];

    // 3. Retrieve your private key, which is encoded in a modified Base64 for URLs, and sign the URL above using the HMAC-SHA1 algorithm.
    NSData *binaryKey = MTDDataWithBase64EncodedString(mtd_cryptographicKey);
    
    // 4. Encode the resulting binary signature using the modified Base64 for URLs to convert this signature into something that can be passed within a URL
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [binaryKey bytes], [binaryKey length], [pathData bytes], [pathData length], &result);
    NSData *binarySignature = [NSData dataWithBytes:&result length:CC_SHA1_DIGEST_LENGTH];

    // 5. Attach this signature to the URL within a signature parameter
    NSString *signature = MTDBase64EncodedStringFromData(binarySignature);

    address = [address stringByAppendingFormat:@"&signature=%@", signature];
    return [NSURL URLWithString:address];
}

- (NSString *)HTTPAddress {
    return kMTDGoogleBaseAddress;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequestGoogle
////////////////////////////////////////////////////////////////////////

+ (void)registerBusinessWithClientId:(NSString *)clientId
                    cryptographicKey:(NSString *)cryptographicKey {
    mtd_clientId = clientId;
    mtd_cryptographicKey = cryptographicKey;
}

+ (BOOL)isBusinessRegistered {
    return mtd_clientId.length > 0 && mtd_cryptographicKey.length > 0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    NSString *locale = MTDDirectionsGetLocaleGoogle();

    [self setValue:@"true" forParameter:@"sensor"];
    [self setValue:locale forParameter:@"language"];

    if ([[self class] isBusinessRegistered]) {
        [self setValue:mtd_clientId forParameter:@"client"];
    }
}

@end
