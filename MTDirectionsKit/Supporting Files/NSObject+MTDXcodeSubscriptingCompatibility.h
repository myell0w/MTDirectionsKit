//
//  NSObject+MTDXcodeSubscriptingCompatibility.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


// Temporary Workaround: Make subscripting work in Xcode 4.4
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSObject (MTDXcodeSubscriptingCompatibility)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

@end

#endif
