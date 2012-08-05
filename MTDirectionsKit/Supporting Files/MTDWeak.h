//
//  MTDWeak.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#if __has_feature(objc_arc_weak)

    #define mtd_weak  weak
    #define __mtd_weak __weak

#else

    #define mtd_weak  unsafe_unretained
    #define __mtd_weak __unsafe_unretained

#endif
