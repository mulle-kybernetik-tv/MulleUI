#import "import.h"


@class CGContext;


//
// CGFont is created and maintained by CGContext, you should not keep a 
// reference to it, as it is only valid during rendering
// 
@interface CGFont : NSObject

@property( assign) char  *name;      // NVG fontName
@property( assign) int   fontIndex;  // NVG index

+ (instancetype) fontWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context;
                     
- (instancetype) initWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context;

@end
