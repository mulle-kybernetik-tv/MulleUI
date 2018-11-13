#import "CALayer.h"

#import "CGGeometry.h"


@implementation CALayer

- (id) init
{
   self = [super init];
   if( ! self)
      return( self);

   _bounds.origin.x = INFINITY;
   return( self);
}


- (BOOL) drawInContext:(NVGcontext *) vg
{
   CGPoint   scale;
   CGRect    frame;
   CGRect    bounds;
   CGFloat   halfBorderWidth;
   CGFloat   halfBorderHeight;
   CGFloat   borderWidth;
   CGFloat   borderHeight;
   CGPoint   tl;
   CGPoint   br;

   frame  = [self frame];
   if( frame.size.width == 0.0 || frame.size.height == 0.0)
      return( NO);

   nvgScissor( vg, frame.origin.x, frame.origin.y, 
                   frame.size.width, frame.size.height);

   fprintf( stderr, "frame.origin: %.1f, %.1f\n", frame.origin.x, frame.origin.y);
   fprintf( stderr, "bounds.origin: %.1f, %.1f\n", bounds.origin.x, bounds.origin.y);

   nvgTranslate( vg, frame.origin.x, frame.origin.y);

   //
   // fill and border are draw in frame
   // contents in bounds
   //

   tl.x = 0.0;
   tl.y = 0.0;
   br.x = frame.size.width - 1;
   br.y = frame.size.height - 1;

   // fill 
   nvgBeginPath( vg);

   nvgMoveTo( vg, tl.x, tl.y);
   nvgLineTo( vg, br.x, tl.y);
   nvgLineTo( vg, br.x, br.y);
   nvgLineTo( vg, tl.x, br.y);
   nvgLineTo( vg, tl.x, tl.y);
   
   nvgFillColor( vg, _backgroundColor);
   nvgFill( vg);


   //
   // the strokeWidth isn't scaled in nvg, so we do this now ourselves
   //
   if( _borderWidth)
   {
      halfBorderWidth = _borderWidth / 2.0;
      nvgStrokeColor( vg, _borderColor);

      tl.x += halfBorderWidth;
      tl.y += halfBorderWidth;
      br.x += -halfBorderWidth;
      br.y += -halfBorderWidth;

      nvgStrokeWidth( vg, _borderWidth);

      nvgBeginPath( vg);
      nvgMoveTo( vg, tl.x, tl.y);
      nvgLineTo( vg, br.x, tl.y);
      nvgLineTo( vg, br.x, br.y);
      nvgLineTo( vg, tl.x, br.y);
      nvgLineTo( vg, tl.x, tl.y);
      nvgStroke( vg);
   }

   bounds = [self bounds];
   if( bounds.size.width == 0.0 || bounds.size.height == 0.0)
      return( NO);

   //
   // now translate bounds for context
   //
   scale.x = frame.size.width / bounds.size.width;
   scale.y = frame.size.height / bounds.size.height;

   nvgScale( vg, scale.x, scale.y);

   nvgTranslate( vg, bounds.origin.x, bounds.origin.y);

   return( YES);
}


- (CGRect) bounds
{
   CGRect  bounds;

   // not tied to frame anymore ? 
   if( _bounds.origin.x != INFINITY)
      return( _bounds);

   bounds.origin = CGPointMake( 0.0f, 0.0f);
   bounds.size   = _frame.size;
   return( bounds);
}

@end

