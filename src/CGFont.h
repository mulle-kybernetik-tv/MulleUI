#import "import.h"


@class CGContext;


//
// CGFont is created and maintained by CGContext, you should not keep a
// reference to it, as it is only valid during rendering
//
@interface CGFont : NSObject

@property( assign) char  *nameCString;      // NVG fontName
@property( assign) int   fontIndex;         // NVG index

+ (instancetype) fontWithNameCString:(char *) name
                           fontIndex:(int) fontIndex;

- (instancetype) initWithNameCString:(char *) name
                           fontIndex:(int) fontIndex;


@end
