#import <MulleObjC/MulleObjC.h>
#import "CGBase.h"

#import "nanovg.h"

typedef NVGcolor   CGColorRef;

@interface CALayer : NSObject  

- (instancetype) init;

- (BOOL) drawInContext:(NVGcontext *) ctx;

@property CGFloat cornerRadius;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property CGColorRef backgroundColor;

@property CGRect frame;
@property CGRect bounds;

@end
