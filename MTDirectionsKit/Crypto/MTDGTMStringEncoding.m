#import "MTDGTMStringEncoding.h"


#define kMTDCharUnknown        -1
#define kMTDCharPadding        -2
#define kMTDCharIgnore         -3


NS_INLINE int lcm(int a, int b) {
    for (int aa = a, bb = b ; ; ) {
        if (aa == bb) {
            return aa;
        } else if (aa < bb) {
            aa += a;
        } else {
            bb += b;
        }
    }
}


@implementation MTDGTMStringEncoding {
    NSData *_charMapData;
    char *_charMap;
    int _reverseCharMap[128];
    int _shift;
    int _mask;
    BOOL _doPad;
    char _paddingChar;
    int _paddingLength;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)rfc4648Base64WebsafeStringEncoding {
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
    NSUInteger outLen = inLen * ((NSUInteger)_shift) / 8;
    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;
    int buffer = 0;
    int bitsLeft = 0;
    BOOL expectPad = NO;

    for (NSUInteger i = 0; i < inLen; i++) {
        int val = _reverseCharMap[(int)inBuf[i]];

        switch (val) {
            case kMTDCharIgnore: {
                break;
            }

            case kMTDCharPadding: {
                expectPad = YES;
                break;
            }

            case kMTDCharUnknown: {
                return nil;
            }

            default: {
                if (expectPad) {
                    return nil;
                }
                buffer <<= _shift;
                buffer |= val & _mask;
                bitsLeft += _shift;
                if (bitsLeft >= 8) {
                    outBuf[outPos++] = (unsigned char)(buffer >> (bitsLeft - 8));
                    bitsLeft -= 8;
                }
                break;
            }
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
    NSUInteger outLen = (inLen * 8 + (NSUInteger)_shift - 1) / (NSUInteger)_shift;

    if (_doPad) {
        outLen = ((outLen + (NSUInteger)_paddingLength - 1) / (NSUInteger)_paddingLength) * (NSUInteger)_paddingLength;
    }

    NSMutableData *outData = [NSMutableData dataWithLength:outLen];
    unsigned char *outBuf = (unsigned char *)[outData mutableBytes];
    NSUInteger outPos = 0;
    int buffer = inBuf[inPos++];
    int bitsLeft = 8;

    while (bitsLeft > 0 || inPos < inLen) {
        if (bitsLeft < _shift) {
            if (inPos < inLen) {
                buffer <<= 8;
                buffer |= (inBuf[inPos++] & 0xff);
                bitsLeft += 8;
            } else {
                int pad = _shift - bitsLeft;
                buffer <<= pad;
                bitsLeft += pad;
            }
        }

        int idx = (buffer >> (bitsLeft - _shift)) & _mask;

        bitsLeft -= _shift;
        outBuf[outPos++] = (unsigned char)_charMap[idx];
    }

    if (_doPad) {
        while (outPos < outLen) {
            outBuf[outPos++] = (unsigned char)_paddingChar;
        }
    }

    [outData setLength:outPos];

    return [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        _charMapData = [string dataUsingEncoding:NSASCIIStringEncoding];

        if (!_charMapData) {
            return nil;
        }
        _charMap = (char *)[_charMapData bytes];
        NSUInteger length = [_charMapData length];

        if (length < 2 || length > 128 || length & (length - 1)) {
            return nil;
        }

        memset(_reverseCharMap, kMTDCharUnknown, sizeof(_reverseCharMap));

        for (NSUInteger i = 0; i < length; i++) {
            if (_reverseCharMap[(int)_charMap[i]] != kMTDCharUnknown) {
                return nil;
            }
            _reverseCharMap[(int)_charMap[i]] = (int)i;
        }

        for (NSUInteger i = 1; i < length; i <<= 1) {
            _shift++;
        }

        _mask = (1 << _shift) - 1;
        _paddingLength = lcm(8, _shift) / _shift;
        _doPad = YES;
    }

    return self;
}

- (void)setPaddingChar:(char)c {
    _paddingChar = c;
    _reverseCharMap[(int)c] = kMTDCharPadding;
}

@end

