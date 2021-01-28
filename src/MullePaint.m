//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MullePaint.h"

#import "import-private.h"

#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif
#ifdef __has_include
# if __has_include( "MulleBitmapImage.h")
#  import "MulleBitmapImage.h"
# endif
#endif


@implementation MullePaint


- (instancetype) initWithNVGpaint:(struct NVGpaint) paint
                        CGContext:(CGContext *) context;
{
   _paint   = paint;
   _context = context;

   return( self);
}

// the paint is valid for the NVGcontext only, but the nvg context is
// not kept, and the nvgContext doesnt keep the paint
- (instancetype) initLinearGradientWithStartPoint:(CGPoint) start
                                         endPoint:(CGPoint) end 
                                       innerColor:(CGColorRef) innerColor
                                       outerColor:(CGColorRef) outerColor
                                        CGContext:(CGContext *) context
{               
   // todo move to CGContext
   _paint = nvgLinearGradient( [context nvgContext], start.x, start.y, end.x, end.y,
                               innerColor, outerColor);
   _context = context;
   return( self);
}                  


- (instancetype) initImagePatternWithBitmapImage:(MulleBitmapImage *) image
                                          origin:(CGPoint) origin         
                                             end:(CGPoint) end         
                                           angle:(CGFloat) angle
                                           alpha:(CGFloat) alpha
                                       CGContext:(CGContext *) context
{
//   CGSize    size;
//
//   size = [image size];
   _paint = nvgImagePattern( [context nvgContext], 
                             origin.x, origin.y, 
                             end.x, end.y,
       	                    angle, 
                             [context registerTextureIDForImage:image], 
                             alpha);
   _context = context;
   return( self);                             
}                           


- (CGColorRef) innerColor
{
   return( _paint.innerColor);
}

- (CGColorRef) outerColor
{
   return( _paint.outerColor);
}

- (CGFloat) radius
{
   return( _paint.radius);
}

- (CGFloat) feather
{
   return( _paint.feather);
}


- (struct NVGpaint) nvgPaint
{
   return( _paint);
}


- (void) finalize
{
   [_bitmapImage autorelease];
   _bitmapImage = nil;

   [super finalize]; // call anywhere you like
}

@end
