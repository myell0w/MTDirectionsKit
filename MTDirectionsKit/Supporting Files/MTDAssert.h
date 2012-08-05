//
//  MTDAssert.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


// Debug Branch, asserts should fail
#ifdef MTD_DEBUG

// Log error and abort in case condition evaluates to NO
#define MTDAssert(condition, ...) do { if ((condition) == NO) { MTDLogAlways(__VA_ARGS__); assert(condition); }} while(0)

// Release Branch, we block assertions in release branch and only log errors
#else

// Only Log error
#define MTDAssert(condition, ...) do { if ((condition) == NO) { MTDLogAlways(__VA_ARGS__); }} while(0)

#endif
