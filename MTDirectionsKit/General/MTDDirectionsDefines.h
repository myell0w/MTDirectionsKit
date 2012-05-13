//
//  MTDDirectionsDefines.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDDirectionsOverlay;
@class MTDMapView;


////////////////////////////////////////////////////////////////////////
#pragma mark - Defines
////////////////////////////////////////////////////////////////////////

#define MTDInvalidCLLocationCoordinate2D CLLocationCoordinate2DMake(-100., -100.)

#define MTDDirectionsKitErrorDomain      @"MTDDirectionsKitErrorDomain"
#define MTDDirectionsKitDataKey          @"MTDDirectionsKitDataKey"


////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs
////////////////////////////////////////////////////////////////////////

typedef void (^mtd_parser_block)(MTDDirectionsOverlay *overlay, NSError *error);
typedef void (^mtd_directions_block)(MTDMapView *mapView, NSError *error);