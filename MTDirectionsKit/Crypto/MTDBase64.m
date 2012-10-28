#import "MTDBase64.h"
#import "MTDGTMStringEncoding.h"


MTDGTMStringEncoding *mtd_encoding = nil;


NSData* MTDDataWithBase64EncodedString(NSString *string) {
    if (mtd_encoding == nil) {
        mtd_encoding = [MTDGTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    }
    
    return [mtd_encoding decode:string];
}

NSString* MTDBase64EncodedStringFromData(NSData *data) {
    if (mtd_encoding == nil) {
        mtd_encoding = [MTDGTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    }
    
    return [mtd_encoding encode:data];
}
