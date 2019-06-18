#import "import.h"


@class CGContext;


@interface CGFont : NSObject

@property(assign) char  *name;  // NVG index
@property(assign) int   fontIndex;  // NVG index

+ (instancetype) fontWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context;
                     
- (instancetype) initWithName:(char *) name
                        bytes:(void *) bytes
                       length:(NSUInteger) length
                      context:(CGContext *) context;

@end
