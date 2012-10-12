#import "MTDMeasurementSystem.h"


#define kMTDMeasurementSystemMetric     @"Metric"
#define kMTDMetersToFeet                3.2808399
#define kMTDMetersCutoff                1000.
#define kMTDFeetCutoff                  3281.
#define kMTDFeetInMiles                 5280.


static MTDMeasurementSystem mtd_measurementSystem = (MTDMeasurementSystem)-1;
static NSNumberFormatter *mtd_numberFormatter = nil;


NS_INLINE __attribute__((constructor)) void MTDLoadMeasurementSystem(void) {
    @autoreleasepool {
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        NSString *measurementSystem = [locale objectForKey:NSLocaleMeasurementSystem];

        if ([measurementSystem isEqualToString:kMTDMeasurementSystemMetric]) {
            MTDDirectionsSetMeasurementSystem(MTDMeasurementSystemMetric);
        } else {
            MTDDirectionsSetMeasurementSystem(MTDMeasurementSystemUS);
        }
    }
}

MTDMeasurementSystem MTDDirectionsGetMeasurementSystem(void) {
    return mtd_measurementSystem;
}

void MTDDirectionsSetMeasurementSystem(MTDMeasurementSystem measurementSystem) {
    if (measurementSystem == MTDMeasurementSystemMetric || measurementSystem == MTDMeasurementSystemUS) {
        mtd_measurementSystem = measurementSystem;
        
        MTDLogVerbose(@"Measurement System was set to %@",
                      (mtd_measurementSystem == MTDMeasurementSystemMetric ? @"Metric" : @"U.S."));
    }
}

NSString* MTDGetFormattedDistanceInMeasurementSystem(CLLocationDistance distance, MTDMeasurementSystem measurementSystem) {
    NSString *format = nil;
    
    if (measurementSystem == MTDMeasurementSystemMetric) {
        if (distance < kMTDMetersCutoff) {
            format = @"%@ m";
        } else {
            format = @"%@ km";
            distance = distance / 1000.;
        }
    } else {
        distance = distance * kMTDMetersToFeet;
        if (distance < kMTDFeetCutoff) {
            format = @"%@ ft";
        } else {
            format = @"%@ miles";
            distance = distance / kMTDFeetInMiles;
        }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mtd_numberFormatter = [NSNumberFormatter new];
        
        [mtd_numberFormatter setLocale:[NSLocale currentLocale]];
        [mtd_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [mtd_numberFormatter setMaximumFractionDigits:1];
    });
    
    return [NSString stringWithFormat:format, [mtd_numberFormatter stringFromNumber:@(distance)]];
}
