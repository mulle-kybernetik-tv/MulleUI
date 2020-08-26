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

- (id) initWithLayer:(CALayer *) layer
{
   self = [super initWithLayer:layer];

   //
   if( self)
   {
      _clickOrDrag._mouseMotionSuppressionDelay = [[self class] mouseMotionSuppressionDelay];
   }
   return( self);
}

/*
 * left mouse
 */
- (UIEvent *) mouseDown:(UIEvent *) event
{
   event = [[self superview] mouseDown:event];
   if( event)
      return( event);

   // only if we consumed the event, do we want to become first responder
   // for the subsequent mouseUp: or mouseDragged: events
   [self becomeFirstResponder];
   return( event);
}


- (UIEvent *) mouseDragged:(UIMouseMotionEvent *) event
{
   return( [[self superview] mouseDragged:event]);
}


- (UIEvent *) mouseUp:(UIEvent *) event
{
   event = [[self superview] mouseUp:event];
   if( event)
      return( event);

   // can only resign here, because UIScrollView still needs to figure out
   // if event came from us
   [self resignFirstResponder];
   return( event);
}

/*
 * right mouse
 */
- (UIEvent *) rightMouseDown:(UIEvent *) event
{
   event = [[self superview] rightMouseDown:event];
   if( event)
      return( event);

   // only if we consumed the event, do we want to become first responder
   // for the subsequent rightMouseDown: or rightMouseDragged: events
   if( ! [self isFirstResponder])
      [self becomeFirstResponder];
   return( event);
}


- (UIEvent *) rightMouseDragged:(UIMouseMotionEvent *) event
{
   return( [[self superview] rightMouseDragged:event]);
}


- (UIEvent *) rightMouseUp:(UIEvent *) event
{
   event = [[self superview] rightMouseUp:event];
   if( event)
      return( event);

   // can only resign here, because UIScrollView still needs to figure out
   // if event came from us
   [self resignFirstResponder];
   return( event);
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
// if point is in bubble, return -1
// otherwise where the bubble would go
//
- (BOOL) isInsideBubbleAtPoint:(CGPoint) point
                      offsetAt:(CGPoint *) offset
{
   CGRect   bubbleFrame;
   CGRect   bounds;
   BOOL     isHorizontal;

   // the frame as actually drawn
   bounds       = [self bounds];
   bubbleFrame  = [self bubbleFrameWithBounds:bounds];

   isHorizontal = bounds.size.width > bounds.size.height;
   if( isHorizontal)
   {
      fprintf( stderr, "P: %s F: %s B:%s:",
            CGPointCStringDescription( point),
            CGRectCStringDescription( bubbleFrame),
            CGRectCStringDescription( bounds));
      offset->y = 0.0; 
      offset->x = point.x - CGRectGetMinX( bubbleFrame); 
      return( point.x >= CGRectGetMinX( bubbleFrame) && 
              point.x <= CGRectGetMaxX( bubbleFrame));
   }

   offset->x = 0.0; 
   offset->y = point.y - CGRectGetMinY( bubbleFrame); 

   return( point.y >= CGRectGetMinY( bubbleFrame) && 
           point.y <= CGRectGetMaxY( bubbleFrame));
}


//
// if point is in bubble, return -1
// otherwise where the bubble would go
//
- (CGFloat) bubbleValueAtPoint:(CGPoint) point
                isInsideBubble:(BOOL *) isInsideBubble
{
   CGRect         bubbleFrame;
   CGRect         bounds;
   BOOL           isHorizontal;
   UIEdgeInsets   insets;
   // the frame as actually drawn
   bounds       = [self bounds];
   bubbleFrame  = [self bubbleFrameWithBounds:bounds];

   // actual limit of bubbleFrame
   insets = UIEdgeInsetsMake( 1.0, 1.0, 1.0, 1.0);
   bounds = UIEdgeInsetsInsetRect( bounds, insets);

   isHorizontal = bounds.size.width > bounds.size.height;
   if( isHorizontal)
   {
      fprintf( stderr, "P: %s F: %s B:%s:",
            CGPointCStringDescription( point),
            CGRectCStringDescription( bubbleFrame),
            CGRectCStringDescription( bounds));

      *isInsideBubble = point.x >= CGRectGetMinX( bubbleFrame) && 
                        point.x <= CGRectGetMaxX( bubbleFrame);
      if( *isInsideBubble)
      {
         fprintf( stderr, "stay put\n");
         return( bubbleFrame.origin.x);
      }

      // center bubble around click
      point.x -= bubbleFrame.size.width / 2.0; 

      if( point.x < CGRectGetMinX( bounds))
      {
         fprintf( stderr, "left edge\n");
         return( CGRectGetMinX( bounds));
      }
      if( point.x + bubbleFrame.size.width > CGRectGetMaxX( bounds))
      {
         fprintf( stderr, "right edge\n");
         return( CGRectGetMaxX( bounds) - bubbleFrame.size.width);
      }

      fprintf( stderr, "%.2f\n", point.x);
      return( point.x);
   }

   *isInsideBubble = point.y >= CGRectGetMinY( bubbleFrame) && 
                     point.y <= CGRectGetMaxY( bubbleFrame);
      if( *isInsideBubble)
         return( bubbleFrame.origin.x);   

   point.y -= bubbleFrame.size.height / 2.0; 

   if( point.y < CGRectGetMinY( bounds))
      return( CGRectGetMinY( bounds));
   if( point.y + bubbleFrame.size.height > CGRectGetMaxY( bounds))
      return( CGRectGetMaxY( bounds) - bubbleFrame.size.height);
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

   vg     = [context nvgContext];
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
											 	 nvgRGBA(128,128,128,160), 
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
