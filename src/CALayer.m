#import "import-private.h"

#import "CALayer.h"

#import "CGGeometry.h"
#import "CGContext.h"


static NVGcolor getNVGColor(uint32_t color) 
{
	return nvgRGBA(
		(color >> 24) & 0xff,
		(color >> 16) & 0xff,
		(color >> 8) & 0xff,
		(color >> 0) & 0xff);
}



@implementation CALayer

- (id) init
{
   self = [super init];
   if( ! self)
      return( self);

   _bounds.origin.x = INFINITY;
   return( self);
}


- (instancetype) initWithFrame:(CGRect) frame
{
   self = [self init];
   if( self)
      _frame = frame;
   return( self);
}


- (BOOL) drawInContext:(CGContext *) context
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
   CGSize    sz;
   int       radius;
   NVGcontext   *vg;
      
   vg = [context nvgContext];

   frame  = [self frame];
   if( frame.size.width == 0.0 || frame.size.height == 0.0)
      return( NO);

   nvgScissor( vg, frame.origin.x, 
                   frame.origin.y, 
                   frame.size.width, 
                   frame.size.height);

//   fprintf( stderr, "frame.origin: %.1f, %.1f\n", frame.origin.x, frame.origin.y);
//   fprintf( stderr, "frame.size: %.1f, %.1f\n", frame.size.width, frame.size.width);
//   fprintf( stderr, "bounds.origin: %.1f, %.1f\n", bounds.origin.x, bounds.origin.y);

   nvgTranslate( vg, frame.origin.x, frame.origin.y);

   //
   // fill and border are draw in frame
   // contents in bounds
   //

   tl.x = _borderWidth;
   tl.y = _borderWidth;
   br.x = frame.size.width - _borderWidth - 1;
   br.y = frame.size.height - _borderWidth - 1;

   if( tl.x <= br.x || tl.y <= br.y)
   {
      // fill 
      nvgBeginPath( vg);

      radius = 0.0;
      if( _borderWidth == 0.0)
         radius = (int) _cornerRadius;

      nvgRoundedRect( vg, tl.x, 
                          tl.y, 
                          br.x - tl.x + 1, 
                          br.y - tl.y + 1, 
                          (int) radius);

   //   nvgMoveTo( vg, tl.x, tl.y);
   //   nvgLineTo( vg, br.x, tl.y);
   //   nvgLineTo( vg, br.x, br.y);
   //   nvgLineTo( vg, tl.x, br.y);
   //   nvgLineTo( vg, tl.x, tl.y);
      
      nvgFillColor( vg, _backgroundColor);
      nvgFill( vg);
   }

   //
   // the strokeWidth isn't scaled in nvg, so we do this now ourselves
   //
   if( _borderWidth)
   {
      if( tl.x <= br.x || tl.y <= br.y)

      halfBorderWidth = _borderWidth / 2.0;
      nvgStrokeColor( vg, _borderColor);

      tl.x = halfBorderWidth;
      tl.y = halfBorderWidth;
      br.x = frame.size.width - halfBorderWidth - 1;
      br.y = frame.size.height - halfBorderWidth - 1;

      if( tl.x <= br.x || tl.y <= br.y)
      {
         nvgStrokeWidth( vg, _borderWidth);

         nvgBeginPath( vg);

         nvgRoundedRect( vg, halfBorderWidth, 
                             halfBorderWidth, 
                             br.x - tl.x + 1, 
                             br.y - tl.y + 1, 
                             (int) _cornerRadius);

//      nvgMoveTo( vg, tl.x, tl.y);
//      nvgLineTo( vg, br.x, tl.y);
//      nvgLineTo( vg, br.x, br.y);
//      nvgLineTo( vg, tl.x, br.y);
//      nvgLineTo( vg, tl.x, tl.y);
        nvgStroke( vg);
      }
   }

   bounds = [self bounds];
   if( bounds.size.width == 0.0 || bounds.size.height == 0.0)
      return( NO);

   //
   // TODO: move this code to UIView (gut feeling)
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

