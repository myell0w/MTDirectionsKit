#import "MTDMeasurementSystem.h"


#define kMTDMeasurementSystemMetric     @"Metric"
#define kMTDMetersToFeet                3.2808399
#define kMTDMetersToMiles               0.000621371192
#define kMTDMetersCutoff                1000.
#define kMTDFeetCutoff                  3281.
#define kMTDFeetInMiles                 5280.


static MTDMeasurementSystem mtd_measurementSystem = -1;
static NSNumberFormatter *mtd_numberFormatter = nil;


MTDMeasurementSystem MTDDirectionsGetMeasurementSystem(void) {
    if (mtd_measurementSystem == -1) {
        NSString *measurementSystem = [[NSLocale systemLocale] objectForKey:NSLocaleMeasurementSystem];
        
        if ([measurementSystem isEqualToString:kMTDMeasurementSystemMetric]) {
            mtd_measurementSystem = MTDMeasurementSystemMetric;
        } else {
            mtd_measurementSystem = MTDMeasurementSystemUS;
        }
    }
    
    return mtd_measurementSystem;
}

void MTDDirectionsSetMeasurementSystem(MTDMeasurementSystem measurementSystem) {
    if (measurementSystem == MTDMeasurementSystemMetric || measurementSystem == MTDMeasurementSystemUS) {
        mtd_measurementSystem = measurementSystem;
    }
}

NSString* MTDFormattedDistanceInMeasurementSystem(CLLocationDistance distance, MTDMeasurementSystem measurementSystem) {
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
        mtd_numberFormatter = [[NSNumberFormatter alloc] init];
        
        [mtd_numberFormatter setLocale:[NSLocale currentLocale]];
        [mtd_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [mtd_numberFormatter setMaximumFractionDigits:1];
    });
    
    return [NSString stringWithFormat:format, [mtd_numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]]];
}
