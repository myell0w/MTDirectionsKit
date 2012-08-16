#import "MTDGTMStringEncoding.h"


enum {
    kUnknownChar = -1,
    kPaddingChar = -2,
    kIgnoreChar  = -3
};


NS_INLINE int lcm(int a, int b) {
    for (int aa = a, bb = b;;) {
        if (aa == bb)
            return aa;
        else if (aa < bb)
            aa += a;
        else
            bb += b;
    }
}


@implementation MTDGTMStringEncoding {
    NSData *charMapData_;
    char *charMap_;
    int reverseCharMap_[128];
    int shift_;
    int mask_;
    BOOL doPad_;
    char paddingChar_;
    int padLen_;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)rfc4648Base64WebsafeStringEncoding {
    MTDGTMStringEncoding *ret = [[[self class] alloc] initWithString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"];

    [ret setPaddingChar:'='];

    return ret;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - GTMStringEncoding
////////////////////////////////////////////////////////////////////////

- (NSData *)decode:(NSString *)inString {
    char *inBuf = (char *)[inString cStringUsingEncoding:NSASCIIStringEncoding];
    if (!inBuf) {
        return nil;
    }
    NSUInteger inLen = strlen(inBuf);

    NSUInteger outLen = inLen * ((NSUInteger)shift_) / 8;
    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;

    int buffer = 0;
    int bitsLeft = 0;
    BOOL expectPad = NO;
    for (NSUInteger i = 0; i < inLen; i++) {
        int val = reverseCharMap_[(int)inBuf[i]];
        switch (val) {
            case kIgnoreChar:
                break;
            case kPaddingChar:
                expectPad = YES;
                break;
            case kUnknownChar:
                return nil;
            default:
                if (expectPad) {
                    return nil;
                }
                buffer <<= shift_;
                buffer |= val & mask_;
                bitsLeft += shift_;
                if (bitsLeft >= 8) {
                    outBuf[outPos++] = (unsigned char)(buffer >> (bitsLeft - 8));
                    bitsLeft -= 8;
                }
                break;
        }
    }
    
    if (bitsLeft && buffer & ((1 << bitsLeft) - 1)) {
        return nil;
    }
    
    // Shorten buffer if needed due to padding chars
    [outData setLength:outPos];
    
    return outData;
}

- (NSString *)encode:(NSData *)inData {
    NSUInteger inLen = [inData length];
    if (inLen <= 0) {
        return @"";
    }
    unsigned char *inBuf = (unsigned char *)[inData bytes];
    NSUInteger inPos = 0;

    NSUInteger outLen = (inLen * 8 + (NSUInteger)shift_ - 1) / (NSUInteger)shift_;
    if (doPad_) {
        outLen = ((outLen + (NSUInteger)padLen_ - 1) / (NSUInteger)padLen_) * (NSUInteger)padLen_;
    }
    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;

    int buffer = inBuf[inPos++];
    int bitsLeft = 8;
    while (bitsLeft > 0 || inPos < inLen) {
        if (bitsLeft < shift_) {
            if (inPos < inLen) {
                buffer <<= 8;
                buffer |= (inBuf[inPos++] & 0xff);
                bitsLeft += 8;
            } else {
                int pad = shift_ - bitsLeft;
                buffer <<= pad;
                bitsLeft += pad;
            }
        }
        int idx = (buffer >> (bitsLeft - shift_)) & mask_;
        bitsLeft -= shift_;
        outBuf[outPos++] = (unsigned char)charMap_[idx];
    }

    if (doPad_) {
        while (outPos < outLen)
            outBuf[outPos++] = (unsigned char)paddingChar_;
    }

    [outData setLength:outPos];
    
    return [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        charMapData_ = [string dataUsingEncoding:NSASCIIStringEncoding];
        if (!charMapData_) {
            return nil;
        }
        charMap_ = (char *)[charMapData_ bytes];
        NSUInteger length = [charMapData_ length];
        if (length < 2 || length > 128 || length & (length - 1)) {
            return nil;
        }

        memset(reverseCharMap_, kUnknownChar, sizeof(reverseCharMap_));
        for (NSUInteger i = 0; i < length; i++) {
            if (reverseCharMap_[(int)charMap_[i]] != kUnknownChar) {
                return nil;
            }
            reverseCharMap_[(int)charMap_[i]] = (int)i;
        }

        for (NSUInteger i = 1; i < length; i <<= 1)
            shift_++;
        mask_ = (1 << shift_) - 1;
        padLen_ = lcm(8, shift_) / shift_;
        doPad_ = YES;
    }
    
    return self;
}

- (void)setPaddingChar:(char)c {
    paddingChar_ = c;
    reverseCharMap_[(int)c] = kPaddingChar;
}

@end

