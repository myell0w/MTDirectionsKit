#import "MTDFunctionsTest.h"


@implementation MTDFunctionsTest

- (void)testURLEncoding {
    NSString *parameter = @"ä_ü_ö_ß_!*'();@&=+$,/?%#[]";
    NSString *encodedParameter = MTDURLEncodedString(parameter);

    STAssertEqualObjects(encodedParameter, @"ae_ue_oe_ss_%21%2A%27%28%29%3B%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D", @"URL encoding not working properly");
}

- (void)testFormattedTime {
    NSTimeInterval time1 = 0.;
    NSTimeInterval time2 = 60.;
    NSTimeInterval time3 = 3600.;
    NSTimeInterval time4 = 3601.;
    NSTimeInterval time5 = 230000.;

    STAssertEqualObjects(MTDGetFormattedTime(time1), @"0:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTime(time2), @"01:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTime(time3), @"1:00:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTime(time4), @"1:00:01", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTime(time5), @"15:53:20", @"MTDGetFormattedTime not working");
}

- (void)testFormattedTimeWithFormat {
    NSTimeInterval time1 = -10.;
    NSTimeInterval time2 = 0.;
    NSTimeInterval time3 = 60.;
    NSTimeInterval time4 = 3600.;
    NSTimeInterval time5 = 3601.;
    NSTimeInterval time6 = 230000.;
    NSString *format = @"HH:m:ss";

    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time1,format), @"0:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time2,format), @"0:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time3,format), @"00:1:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time4,format), @"01:0:00", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time5,format), @"01:0:01", @"MTDGetFormattedTime not working");
    STAssertEqualObjects(MTDGetFormattedTimeWithFormat(time6,format), @"15:53:20", @"MTDGetFormattedTime not working");
}

- (void)testStringFromLocationCoordinate {
    CLLocationCoordinate2D valid = CLLocationCoordinate2DMake(40.1, 42.);
    CLLocationCoordinate2D invalid = kCLLocationCoordinate2DInvalid;

    STAssertEqualObjects(MTDStringFromCLLocationCoordinate2D(valid), @"(40.100000,42.000000)", @"MTDStringFromCLLocationCoordinate2D not working for valid coordinate.");
    STAssertEqualObjects(MTDStringFromCLLocationCoordinate2D(invalid), @"Invalid CLLocationCoordinate2D", @"MTDStringFromCLLocationCoordinate2D not working for invalid coordinate.");
}

- (void)testObjectAtIndex {
    NSArray *array = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", nil];

    STAssertEqualObjects(MTDFirstObjectOfArray(array), @"A", @"First object of array not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 0), @"A", @"Object at index not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 1), @"B", @"Object at index not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 2), @"C", @"Object at index not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 3), @"D", @"Object at index not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 4), nil, @"Object at index not working");
    STAssertEqualObjects(MTDObjectAtIndexOfArray(array, 5), nil, @"Object at index not working");
}

- (void)testOrderedArray {
    NSArray *array = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", nil];
    NSArray *sequence = [NSArray arrayWithObjects:@"0", @"2", @"1", @"3", nil];
    NSArray *orderedArray = MTDOrderedArrayWithSequence(array, sequence);

    STAssertEqualObjects([orderedArray componentsJoinedByString:@""], @"ACBD", @"Ordering of Array not working");
}

@end
