//
//  MTDDirectionsDefines.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDDirectionsOverlay;
@class MTDMapView;


////////////////////////////////////////////////////////////////////////
#pragma mark - Defines
////////////////////////////////////////////////////////////////////////

// NSError-related constants
#define MTDDirectionsKitErrorDomain      @"MTDDirectionsKitErrorDomain"
#define MTDDirectionsKitDataKey          @"MTDDirectionsKitDataKey"
#define MTDDirectionsKitErrorMessageKey  @"MTDDirectionsKitErrorMessageKey"


////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs
////////////////////////////////////////////////////////////////////////

// block that is passed to an instance of MTDDirectionsParser and reports success/failure of parsing
typedef void (^mtd_parser_block)(MTDDirectionsOverlay *overlay, NSError *error);
