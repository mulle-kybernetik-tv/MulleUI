//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#ifdef __has_include
# if __has_include( "CGColor.h")
#  import "CGColor.h"
# endif
#endif

#import "import.h"


@class MulleBitmapImage;
@class CGContext;


// Paint is either a gradient or a texture. Actually behind the scenes
// its a texture anyway :)

@interface MullePaint : NSObject
{
   struct NVGpaint     _paint;
}

@property( readonly, assign) CGContext         *context;
@property( readonly, retain) MulleBitmapImage  *bitmapImage;

- (instancetype) initWithNVGpaint:(struct NVGpaint) paint
                        CGContext:(CGContext *) context;

// the paint is valid for the NVGcontext only, but the nvg context is
// not kept, and the nvgContext doesnt keep the paint
- (instancetype) initLinearGradientWithStartPoint:(CGPoint) start
                                         endPoint:(CGPoint) end 
                                       innerColor:(CGColorRef) innerColor
                                       outerColor:(CGColorRef) outerColor
                                        CGContext:(CGContext *) context;

- (instancetype) initImagePatternWithBitmapImage:(MulleBitmapImage *) image
                                          origin:(CGPoint) origin         
                                             end:(CGPoint) end         
                                           angle:(CGFloat) angle
                                           alpha:(CGFloat) alpha
                                       CGContext:(CGContext *) context;

- (CGColorRef) innerColor;
- (CGColorRef) outerColor;
- (CGFloat) radius;
- (CGFloat) feather;

- (struct NVGpaint) nvgPaint;

@end
