#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"


#define kMTDSecondsPerHour      (60. * 60.)


static NSDateFormatter *mtd_dateFormatter = nil;


BOOL MTDDirectionsOpenInMapsApp(MTDWaypoint *from, MTDWaypoint *to, MTDDirectionsRouteType routeType) {
    if (from.hasValidCoordinate && to.hasValidCoordinate) {
        if (MTDDirectionsSupportsAppleMaps()) {
            MKMapItem *fromMapItem = nil;
            MKMapItem *toMapItem = nil;

            if (from == [MTDWaypoint waypointForCurrentLocation]) {
                fromMapItem = [MKMapItem mapItemForCurrentLocation];
            } else {
                MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:from.coordinate addressDictionary:from.address.addressDictionary];
                fromMapItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
            }

            if (to == [MTDWaypoint waypointForCurrentLocation]) {
                toMapItem = [MKMapItem mapItemForCurrentLocation];
            } else {
                MKPlacemark *toPlacemark = [[MKPlacemark alloc] initWithCoordinate:to.coordinate addressDictionary:to.address.addressDictionary];
                toMapItem = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
            }

            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey: MTDMKLaunchOptionFromMTDDirectionsRouteType(routeType)};
            return [MKMapItem openMapsWithItems:@[fromMapItem, toMapItem] launchOptions:launchOptions];
        }

        // Google Maps
        else {
            NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                                       from.coordinate.latitude,from.coordinate.longitude, to.coordinate.latitude, to.coordinate.longitude];

            switch (routeType) {
                case MTDDirectionsRouteTypePedestrian:
                case MTDDirectionsRouteTypeBicycle: {
                    googleMapsURL = [googleMapsURL stringByAppendingString:@"&dirflg=w"];
                    break;
                }

                case MTDDirectionsRouteTypePedestrianIncludingPublicTransport: {
                    googleMapsURL = [googleMapsURL stringByAppendingString:@"&dirflg=r"];
                    break;
                }

                case MTDDirectionsRouteTypeFastestDriving:
                case MTDDirectionsRouteTypeShortestDriving:
                default: {
                    // do nothing
                    break;
                }
            }

            return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
        }
    }

    return NO;
}

NSString* MTDURLEncodedString(NSString *string) {
    MTDAssert(string != nil, @"String must be set");

    NSMutableString *preparedString = [NSMutableString stringWithString:string];

    // replace umlauts, because they don't work in the MapQuest API
    [preparedString replaceOccurrencesOfString:@"ü" withString:@"ue" options:NSCaseInsensitiveSearch range:NSMakeRange(0, preparedString.length)];
    [preparedString replaceOccurrencesOfString:@"ö" withString:@"oe" options:NSCaseInsensitiveSearch range:NSMakeRange(0, preparedString.length)];
    [preparedString replaceOccurrencesOfString:@"ä" withString:@"ae" options:NSCaseInsensitiveSearch range:NSMakeRange(0, preparedString.length)];
    [preparedString replaceOccurrencesOfString:@"ß" withString:@"ss" options:NSCaseInsensitiveSearch range:NSMakeRange(0, preparedString.length)];

    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[preparedString description],
                                                                                 NULL,
                                                                                 CFSTR("!*'();@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8);
}

NSString* MTDStringByStrippingXMLTags(NSString *string) {
    if (string.length == 0) {
        return nil;
    }

    // This is a simple scanning algorithm that doens't work for arbitrary HTML/XML documents including comments etc.,
    // but it works reliably and fast for the simplified HTML descriptions returned by the Google Directions API
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSString *scannedString = nil;
    NSMutableString *finalString = [NSMutableString stringWithCapacity:string.length];

    scanner.caseSensitive = YES;
    scanner.charactersToBeSkipped = nil;

    while (![scanner isAtEnd]) {
        // scan characters until start of tag
        [scanner scanUpToString:@"<" intoString:&scannedString];
        // scan characters until end of tag
        [scanner scanUpToString:@">" intoString:NULL];
        [scanner scanString:@">" intoString:NULL];

        if (scannedString != nil) {
            [finalString appendFormat:@"%@ ", scannedString];
            scannedString = nil;
        }
    }

    return MTDStringByStrippingUnnecessaryWhitespace(finalString);
}

NSString* MTDStringByStrippingUnnecessaryWhitespace(NSString *string) {
    // Algorithm taken from http://nshipster.com/nscharacterset/
    // You should really read this blog, it's awesome - thanks @mattt!
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];

    string = [components componentsJoinedByString:@" "];

    return string;
}

NSString* MTDGetFormattedTime(NSTimeInterval interval) {
    if (interval < kMTDSecondsPerHour) {
        return MTDGetFormattedTimeWithFormat(interval, @"mm:ss");
    } else {
        return MTDGetFormattedTimeWithFormat(interval, @"H:mm:ss");
    }
}

NSString* MTDGetFormattedTimeWithFormat(NSTimeInterval interval, NSString *format) {
    MTDAssert(format.length > 0, @"Format must be set.");

    if (interval <= 0. || format.length == 0) {
        return @"0:00";
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mtd_dateFormatter = [NSDateFormatter new];
        [mtd_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });

    [mtd_dateFormatter setDateFormat:format];

    return [mtd_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]];
}

NSString* MTDStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        return [NSString stringWithFormat:@"(%6f,%6f)", coordinate.latitude, coordinate.longitude];
    } else {
        return @"Invalid CLLocationCoordinate2D";
    }
}

UIColor* MTDDarkenedColor(UIColor *color, CGFloat difference) {
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    NSUInteger numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);

    if (numberOfComponents != 3) {
        return color;
    }

    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    const CGFloat r = components[0];
    const CGFloat g = components[1];
    const CGFloat b = components[2];

    return [UIColor colorWithRed:MAX(0, r - difference)
                           green:MAX(0, g - difference)
                            blue:MAX(0, b - difference)
                           alpha:alpha];
}

BOOL MTDDirectionLineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect rect) {
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);

    return MKMapRectIntersectsRect(rect, r2);
}

NSArray *MTDOrderedArrayWithSequence(NSArray *array, NSArray *sequence) {
    MTDAssert(array.count == sequence.count, @"Number of elements in array and sequence don't match.");

    if (array.count != sequence.count) {
        return array;
    }

    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSUInteger indexOfObj1 = [array indexOfObject:obj1];
        NSUInteger indexOfObj2 = [array indexOfObject:obj2];

        id sequenceIndex1 = sequence[indexOfObj1];
        id sequenceIndex2 = sequence[indexOfObj2];

        if ([sequenceIndex1 integerValue] < [sequenceIndex2 integerValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

BOOL MTDDirectionsSupportsAppleMaps(void) {
    static BOOL supportsAppleMaps = NO;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportsAppleMaps = NSClassFromString(@"MKDirectionsRequest") != nil;
    });

    return supportsAppleMaps;
}

UIImage *MTDColoredImage(CGSize size, UIColor *color) {
    CGRect rect = (CGRect){CGPointZero, size};
    UIImage *image = nil;

    UIGraphicsBeginImageContext(size);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}
