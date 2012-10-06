#import "MTDDirectionsParserCustomTest.h"
#import "MTDDirectionsRequestBing.h"
#import "MTDDirectionsParserBing.h"
#import "MTDDirectionsAPI.h"


@implementation MTDDirectionsParserCustomTest

- (void)testValidParserSubclass {
    STAssertNoThrow(MTDDirectionsAPIRegisterCustomRequestClass([MTDDirectionsRequestBing class]), @"Can't register valid request class");
    STAssertNoThrow(MTDDirectionsAPIRegisterCustomParserClass([MTDDirectionsParserBing class]), @"Can't register valid parser class");

    STAssertEquals(MTDDirectionsRequestClassForAPI(MTDDirectionsAPICustom), [MTDDirectionsRequestBing class], @"Request class wasn't set");
    STAssertEquals(MTDDirectionsParserClassForAPI(MTDDirectionsAPICustom), [MTDDirectionsParserBing class], @"Parser class wasn't set");
}

@end
