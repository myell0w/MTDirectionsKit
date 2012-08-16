#import "MTDBase64.h"
#import "MTDGTMStringEncoding.h"


MTDGTMStringEncoding *mtd_encoding = nil;


NS_INLINE __attribute__((constructor)) void MTDLoadEncoding() {
    @autoreleasepool {
        mtd_encoding = [MTDGTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    }
}


// TODO: Replace this with a cleaner solution that behaves like GTMStringEncoding
NSData* MTDDataWithBase64EncodedString(NSString *string) {
    return [mtd_encoding decode:string];
}

NSString* MTDBase64EncodedStringFromData(NSData *data) {
    return [mtd_encoding encode:data];
}
