//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CAShapeLayer.h"

#import "import-private.h"

#import "CGContext.h"

#include "CGPath+nanovg.h"


@implementation CAShapeLayer

- (void) setCGPath:(CGPath *) path 
{
   CGPathDestroy( _path);
   _path = path;
}


- (void) dealloc
{
   CGPathDestroy( _path);
   [super dealloc];
}

// needs to restore context if changed
- (BOOL) drawContentsInContext:(CGContext *) context
{
   NVGcontext   *nvg;
   BOOL          fill;
   BOOL          stroke;
   CGRect        frame;
   CGRect        bounds;

   fill   = ! MulleColorIsTransparent( _fillColor);
   stroke = ! MulleColorIsTransparent( _strokeColor);

   if( ! fill && ! stroke)
      return( NO);

   nvg    = [context nvgContext];
   frame  = [self frame];

   // scale untested
   bounds = [self bounds];
   nvgTranslate( nvg, frame.origin.x, frame.origin.y);
   {   
      if( ! CGSizeEqualToSize( frame.size, bounds.size))
      {
         nvgScale( nvg, bounds.size.width / frame.size.width, 
                        bounds.size.height / frame.size.height);
      }

      nvgBeginPath( nvg);
      nvgAddCGPath( nvg, _path);

      if( fill)
      {
         nvgFillColor( nvg, _fillColor);
         nvgFill( nvg);
      }

      if( stroke)
      {
         nvgStrokeColor( nvg, _strokeColor);
         nvgStroke( nvg);
      }
   }   
   return( YES);
}
@end
