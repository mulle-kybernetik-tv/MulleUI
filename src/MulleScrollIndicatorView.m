#import "MulleScrollIndicatorView.h"

#import "UIEdgeInsets.h"
#import "UIView+UIEvent.h"
#import "UIView+UIResponder.h"
#import "CGGeometry+CString.h"
#import "CGContext.h"
#import "nanovg.h"


// #define LAYOUT_DEBUG


@implementation MulleScrollIndicatorView 

+ (Class) layerClass
{
   return( [MulleScrollIndicatorLayer class]);
}

- (UIEvent *) mouseDown:(UIEvent *) event
{
   return( [[self superview] mouseDown:event]);
}

- (UIEvent *) mouseDragged:(UIMouseMotionEvent *) event
{
   return( [[self superview] mouseDragged:event]);
}

- (UIEvent *) mouseUp:(UIEvent *) event
{
   return( [[self superview] mouseUp:event]);
}


- (UIEvent *) rightMouseDown:(UIEvent *) event
{
   return( [[self superview] mouseDown:event]);  // sic
}

- (UIEvent *) rightMouseDragged:(UIMouseMotionEvent *) event
{
   return( [[self superview] mouseDragged:event]);
}

- (UIEvent *) rightMouseUp:(UIEvent *) event
{
   return( [[self superview] mouseUp:event]);  // sic
}

@end


@implementation MulleScrollIndicatorLayer


- (CGRect) bubbleFrameWithBounds:(CGRect) bounds
{
   float         x;
   float         y;
   float         w;
   float         h;
   float         xLimit;
   float         yLimit;
   CGRect        frame;
   BOOL          isHorizontal;
   UIEdgeInsets  insets;

   insets = UIEdgeInsetsMake( 1.0, 1.0, 1.0, 1.0);
   frame  = UIEdgeInsetsInsetRect( bounds, insets);

   isHorizontal = bounds.size.width > bounds.size.height;
   if( isHorizontal)
   {
      xLimit = frame.origin.x + frame.size.width;

      w = frame.size.width * _bubbleLength / _contentLength;
      x = frame.size.width * _bubbleOffset / _contentLength + frame.origin.x;
      if( x + w > xLimit)
         w = xLimit - x;
      if( x < frame.origin.x)
      {
         w -= frame.origin.x - x;
         x  = frame.origin.x;
      }

      // don't let bubble vanish leave a dot of size
      // frame.size.height
      if( w < frame.size.height)
      {
         w = frame.size.height;
         if( x + w > xLimit)
            x = xLimit - w;
      }

      if( x + w <= xLimit)
      {
         frame.origin.x   = x;
         frame.size.width = w;
      }
   }
   else
   {
      yLimit = frame.origin.y + frame.size.height;

      h = frame.size.height * _bubbleLength / _contentLength;
      y = frame.size.height * _bubbleOffset / _contentLength + frame.origin.y;
      if( y + h > yLimit)
         h = yLimit - y;
      if( y < frame.origin.y)
      {
         h -= frame.origin.y - y;
         y  = frame.origin.y;
      }

      // don't let bubble vanish leave a dot of size
      // frame.size.width
      if( h < frame.size.width)
      {
         h = frame.size.width;
         if( y + h > yLimit)
            y = yLimit - h;
      }

      if( y + h <= yLimit)
      {
         frame.origin.y    = y;
         frame.size.height = h;
      }
   }

   return( frame);
}


//
// if point is in bubble, return bubble start
// otherwise where the bubble would go
//
- (CGFloat) bubbleValueAtPoint:(CGPoint) point
{
   CGRect   bubbleFrame;
   CGRect   bounds;
   BOOL     isHorizontal;

   bounds      = [self bounds];

   // the frame as actually drawn
   bubbleFrame = [self bubbleFrameWithBounds:bounds];

   isHorizontal = bounds.size.width > bounds.size.height;
   if( isHorizontal)
   {
      if( CGRectContainsPoint( bubbleFrame, point))
         return( bubbleFrame.origin.x);
      if( point.x + bubbleFrame.size.width > bounds.size.width)
         return( bounds.size.width - bubbleFrame.size.width);
      // try to center point in bubble
      point.x -= bubbleFrame.size.width / 2.0;
      if( point.x < 0.0)
         point.x = 0.0;
      return( point.x);
   }

   if( CGRectContainsPoint( bubbleFrame, point))
      return( bubbleFrame.origin.y);
   if( point.y + bubbleFrame.size.height > bounds.size.height)
      return( bounds.size.height - bubbleFrame.size.height);
   // try to center point in bubble
   point.y -= bubbleFrame.size.height / 2.0;
   if( point.y < 0.0)
      point.y = 0.0;
   return( point.y);
}


- (BOOL) drawInContext:(CGContext *) context 
{
   NVGcontext    *vg;
	NVGpaint      shadowPaint;
	CGRect        bounds;
	CGRect        bubbleFrame;

   if( ! [super drawInContext:context])
      return( NO);

   //
   // don't paint scrollbar if content fits inside scrollView
   //
   if( _bubbleLength >= _contentLength)
   {
#ifdef LAYOUT_DEBUG
  	 	fprintf( stderr, "%s Not showing %s for %.2f >= %.2f\n\n",
   					__PRETTY_FUNCTION__, 
                  [self cStringDescription],
                  _bubbleLength, 
                  _contentLength);
#endif   	
   	return( NO);
   }

   vg = [context nvgContext];

   bounds = [self bounds];
#ifdef LAYOUT_DEBUG
   fprintf( stderr, "bounds bubble: %s\n", CGRectCStringDescription( bounds));      
#endif

   // code stolen from nanovg: demo.c
   // Scroll bar
	shadowPaint = nvgBoxGradient( vg, bounds.origin.x + 1,
											    bounds.origin.y + 1, 
											 	 bounds.size.width, 
											 	 bounds.size.height, 
											 	 3, // radius
											 	 4, // feather
											 	 nvgRGBA(0,0,0,32), 
											 	 nvgRGBA(0,0,0,92));

	nvgBeginPath(vg);
	nvgRoundedRect(vg, bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height, 3);

	nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
	nvgFillColor( vg, nvgRGBA( 255,255,255,128));
	nvgFill( vg);


	nvgGlobalCompositeOperation( vg, NVG_SOURCE_OVER);
	nvgFillPaint(vg, shadowPaint);
	nvgFill( vg);

	// Scroll bubble
	// bubble has offset and size, first scale to complete


   bubbleFrame = [self bubbleFrameWithBounds:bounds];
   
#ifdef LAYOUT_DEBUG
   fprintf( stderr, "bubbleFrame bubble: %s\n", CGRectCStringDescription( bubbleFrame));  		
#endif

	shadowPaint = nvgBoxGradient( vg, bubbleFrame.origin.x,
											    bubbleFrame.origin.y, 
											 	 bubbleFrame.size.width, 
											 	 bubbleFrame.size.height, 
											 	 3, // radius
											 	 4, // feather
											 	 //nvgRGBA(220,120,120,255), 
											 	 //nvgRGBA(128,28,28,255));
											 	 nvgRGBA(156,156,156,160), 
											 	 nvgRGBA(64,64,64,160));

	nvgBeginPath(vg);
	nvgRoundedRect(vg, bubbleFrame.origin.x,
							 bubbleFrame.origin.y, 
							 bubbleFrame.size.width,
							 bubbleFrame.size.height, 
							 2);
	nvgFillPaint(vg, shadowPaint);
//	nvgFillColor(vg, nvgRGBA(0,0,0,128));
	nvgFill(vg);

   return( YES);
}

@end
