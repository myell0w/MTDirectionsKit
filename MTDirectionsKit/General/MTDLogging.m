#import "MTDLogging.h"

// current active log level
static MTDLogLevel mtd_logLevel = MTDLogLevelError;


/**
 This function transforms a log level into a string representation used in the logging string.
 
 @return a description of the log level
 */
NS_INLINE NSString* MTDLogLevelDescription(MTDLogLevel logLevel) {
    switch (logLevel) {
        case MTDLogLevelVerbose:
            return @"<V>";
            
        case MTDLogLevelInfo:
            return @"<I>";
            
        case MTDLogLevelWarning:
            return @"<W>";
            
        case MTDLogLevelError:
            return @"!E!";
            
        case MTDLogLevelNone:
        default:
            return @"";
    }
}

void MTDDirectionsSetLogLevel(MTDLogLevel logLevel) {
    if (logLevel >= MTDLogLevelVerbose && logLevel <= MTDLogLevelNone) {
        mtd_logLevel = logLevel;
    }
}

MTDLogLevel MTDDirectionsGetLogLevel(void) {
    return mtd_logLevel;
}

void MTDLogWithLevel(MTDLogLevel logLevel, NSString *file, unsigned int line, NSString *logMessage) {
    if (logLevel >= mtd_logLevel) {
        printf("MTDirectionsKit[%s:%u] %s %s - %s\n", [file UTF8String], line, [logMessage UTF8String], [MTDLogLevelDescription(logLevel) UTF8String], __TIME__);
    }
}
