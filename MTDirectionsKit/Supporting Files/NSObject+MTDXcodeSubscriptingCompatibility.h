//
//  NSObject+MTDXcodeSubscriptingCompatibility.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


// Temporary Workaround: Make subscripting work in Xcode 4.4
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
/**
 This is a compatibility category to make subscripting work in Xcode 4.4
 */
@interface NSObject (MTDXcodeSubscriptingCompatibility)

/**
 Returns the object at the specified index.
 
 @param idx the index of the object
 @return the object at specified index
 */
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 Replaces the object at the index with the new object, possibly adding the object.
 
 @param obj the new object
 @param idx the index of the new object
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

/**
 Adds a given key-value pair to the object.
 
 @param obj the new object
 @param key the key the object gets associated with
 */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/**
 Returns the value associated with a given key.
 
 @param key the key of the object to query
 @return the object associated with the given key
 */
- (id)objectForKeyedSubscript:(id)key;

@end

#endif
