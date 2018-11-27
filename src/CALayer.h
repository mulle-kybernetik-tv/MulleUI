#import <MulleObjC/MulleObjC.h>
#import "CGBase.h"

#import "nanovg.h"

typedef NVGcolor   CGColorRef;

@class CGContext;


@interface CALayer : NSObject  

- (instancetype) init;
- (instancetype) initWithFrame:(CGRect) frame;

- (BOOL) drawInContext:(CGContext *) ctx;

@property CGFloat cornerRadius;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property CGColorRef backgroundColor;

@property CGRect frame;
@property CGRect bounds;

@end
