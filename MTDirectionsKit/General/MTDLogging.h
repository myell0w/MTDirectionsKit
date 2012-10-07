//
//  MTDLogging.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 The log levels supported by MTDDirectionsKit.
 
 - MTDLogLevelVerbose: Print all log messages
 - MTDLogLevelInfo: Print everything up from info messages
 - MTDLogLevelWarning: Print everything up from warning messages
 - MTDLogLevelError: Only print error messages
 - MTDLogLevelNone: Don't print any log messages
 */
typedef NS_ENUM(NSUInteger, MTDLogLevel) {
    MTDLogLevelVerbose = 0,
    MTDLogLevelInfo,
    MTDLogLevelWarning,
    MTDLogLevelError,
    MTDLogLevelNone
};


/**
 Sets the logging level used in MTDirectionsKit.
 
 @param logLevel the log level to use
 */
void MTDDirectionsSetLogLevel(MTDLogLevel logLevel);

/**
 Returns the current set log level. The default log level used is MTDLogLevelError,
 that means that only errors are logged.
 
 @return the current active log level
 */
MTDLogLevel MTDDirectionsGetLogLevel(void);

/**
 This function logs the log message, if the given logLevel is greater or equal
 to the currently defined global logLevel
 
 @param logLevel the level of the message to log
 @param file the name of the file where the log message was printed
 @param line the line number where the log message was printed
 @param logMessage the message that we want to log
 */
void MTDLogWithLevel(MTDLogLevel logLevel, NSString *file, unsigned int line, NSString *logMessage);


// Shortcuts for logging with the given log levels
#define MTDLogVerbose(...)       MTDLogWithLevel(MTDLogLevelVerbose, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define MTDLogInfo(...)          MTDLogWithLevel(MTDLogLevelInfo, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define MTDLogWarning(...)       MTDLogWithLevel(MTDLogLevelWarning, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define MTDLogError(...)         MTDLogWithLevel(MTDLogLevelError, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define MTDLogAlways(...)        MTDLogWithLevel(MTDLogLevelNone, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:__VA_ARGS__])
