//
//  MTDDirectionsRouteType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 When requesting routing information you can tell your instance of MTDMapView in which way
 the user wants to travel, that means whether he wants to walk, bike or drive.
 
 The following types of travelling are supported currently:
 
 - MTDDirectionsRouteTypeFastestDriving
 - MTDDirectionsRouteTypeShortestDriving
 - MTDDirectionsRouteTypePedestrian
 - MTDDirectionsRouteTypePedestrianIncludingPublicTransport
 - MTDDirectionsRouteTypeBicycle
 */
typedef NS_ENUM(NSUInteger, MTDDirectionsRouteType) {
    MTDDirectionsRouteTypeFastestDriving = 0,
    MTDDirectionsRouteTypeShortestDriving,
    MTDDirectionsRouteTypePedestrian,
    MTDDirectionsRouteTypePedestrianIncludingPublicTransport,
    MTDDirectionsRouteTypeBicycle
};


/**
 On iOS 6 there is a built-in functionality to open the Maps App from your Application.
 This function returns the string representation of the routeType that can be specified
 as launch options in MKMapItem's openMapsWithItems:launchOptions:
 
 Currently there are only two modes possible:
 
  - MKLaunchOptionsDirectionsModeDriving
  - MKLaunchOptionsDirectionsModeWalking
 
 MTDDirectionsRouteTypeFastestDriving and MTDDirectionsRouteTypeShortestDriving will translate
 to MKLaunchOptionsDirectionsModeDriving, the rest to MKLaunchOptionsDirectionsModeWalking.
 
 @param routeType the route type of the directions we want to show
 @return a string representation of the corresponding launch option
 */
NSString* MTDMKLaunchOptionFromMTDDirectionsRouteType(MTDDirectionsRouteType routeType);
