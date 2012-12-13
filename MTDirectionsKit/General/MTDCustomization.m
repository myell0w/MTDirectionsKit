#import "MTDCustomization.h"
#import <objc/runtime.h>


static NSMutableDictionary *mtd_overriddenClasses =  nil;


////////////////////////////////////////////////////////////////////////
#pragma mark - MTDCustomization
////////////////////////////////////////////////////////////////////////

void MTDOverrideClass(Class classToOverride, Class classToUseInstead) {
    MTDAssert(classToOverride != Nil && classToUseInstead != Nil, @"Can't specifiy Nil for class to use or to override");

    if (classToOverride == Nil || classToUseInstead == Nil) {
        return;
    }

    if (mtd_overriddenClasses == nil) {
        mtd_overriddenClasses = [NSMutableDictionary new];
    }

    Class classToCheckHierarchy = classToUseInstead;
    BOOL isSubclass = NO;

    while (classToCheckHierarchy != Nil) {
        if (classToCheckHierarchy == classToOverride) {
            isSubclass = YES;
            break;
        }

        // check superclass in next turn
        classToCheckHierarchy = class_getSuperclass(classToCheckHierarchy);
    }

    MTDAssert(isSubclass, @"You can only override classes with subclasses of them!");

    if (isSubclass) {
        [mtd_overriddenClasses setObject:(id)classToUseInstead forKey:(id<NSCopying>)classToOverride];

        MTDLogVerbose(@"Class '%@' was overridden with class '%@'.", NSStringFromClass(classToOverride), NSStringFromClass(classToUseInstead));
    }
}

Class MTDOverriddenClass(Class baseClass) {
    MTDAssert(baseClass != Nil, @"Can't specifiy Nil for class to use");

    if (baseClass == Nil) {
        return Nil;
    }

    Class overriddenClass = [mtd_overriddenClasses objectForKey:(id<NSCopying>)baseClass];
    
    return overriddenClass ?: baseClass;
}
