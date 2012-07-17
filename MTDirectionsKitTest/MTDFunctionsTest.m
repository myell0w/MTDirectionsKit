#import "MTDFunctionsTest.h"


@implementation MTDFunctionsTest

- (void)testOrderedArray {
    NSArray *array = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", nil];
    NSArray *sequence = [NSArray arrayWithObjects:@"0", @"2", @"1", @"3", nil];
    NSArray *orderedArray = MTDOrderedArrayWithSequence(array, sequence);

    STAssertEqualObjects([orderedArray componentsJoinedByString:@""], @"ACBD", @"Ordering of Array not working");
}

@end
