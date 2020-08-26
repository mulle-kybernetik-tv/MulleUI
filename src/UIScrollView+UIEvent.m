#import "UIScrollView+UIEvent.h"

#import "CGGeometry+CString.h"
#import "UIView+CGGeometry.h"
#import "UIView+UIEvent.h"
#import "UIView+UIResponder.h"
#import "UIEvent.h"
#import "MulleScrollIndicatorView.h"


// #define LAYOUT_DEBUG    
#define EVENT_DEBUG
#define ZOOM_DEBUG
#define SCROLL_DEBUG


@implementation UIScrollView( UIEvent)


//
// event handling
// In category ?
//


//
// point is within { { 0, 0}, contentSize }
//
- (void) centerViewOnPoint:(CGPoint) point
{
   CGPoint   contentOffset;
   CGRect    bounds;

   bounds = [self bounds];

   // center mouse in the middle of the screen
   contentOffset.x = point.x - bounds.size.width / 2.0;
   contentOffset.y = point.y - bounds.size.height / 2.0;
      
   contentOffset = [self clampedContentOffset:contentOffset];
   [self setContentOffset:contentOffset];
}


#define ZOOM_FACTOR    0.075

- (CGPoint) zoomFactor
{
   CGRect   contentBounds;
   CGSize   contentSize;
   CGPoint  zoomFactor;

   contentBounds = [_contentView bounds];

   if( contentBounds.size.width <= 0.1 || contentBounds.size.height <= 0.1)
      return( CGPointMake( 0.0, 0.0));

   // the current scroll factor
   contentSize  = [self contentSize];

   zoomFactor.x = contentSize.width / contentBounds.size.width;
   zoomFactor.y = contentSize.height / contentBounds.size.height;

   return( zoomFactor);
}

#define SCROLL_FACTOR  0.25

- (CGPoint) scrollFactor
{
   CGRect   contentBounds;
   CGSize   contentSize;
   CGPoint  scrollFactor;

   contentBounds = [_contentView bounds];

   if( contentBounds.size.width <= 0.1 || contentBounds.size.height <= 0.1)
      return( CGPointMake( 0.0, 0.0));

   // the current scroll factor
   // contentSize  = [self contentSize];

   scrollFactor.x = SCROLL_FACTOR;
   scrollFactor.y = SCROLL_FACTOR;

   return( scrollFactor);
}

//
// event handling
// In category ?
// Won't zoom out, so that UIScrollView is not filled anymore ?
// Zooming in should stop at a certain magnifying factor, like what ?
//
- (UIEvent *) scrollWheel:(UIMouseScrollEvent *) event
{
   CGPoint   contentOffset;
   CGPoint   diff;
   CGPoint   factor;
   CGPoint   mouseLocation;
   CGPoint   newContentOffset;
   CGPoint   scale;
   CGPoint   zoomFactor;
   CGPoint   newZoomFactor;
   CGPoint   scrollFactor;
   CGRect    bounds;
   CGRect    contentBounds;
   CGRect    newContentBounds;
   CGSize    contentSize;
   UIView    *contentView;

   diff = [event scrollOffset];

   contentOffset = [self contentOffset];
   contentSize   = [self contentSize];

   // get unscaled position before zoom
   contentView   = [self contentView];
   contentBounds = [contentView bounds];

#ifdef EVENT_DEBUG
   fprintf( stderr, "scrollWheel: %s\n", CGPointCStringDescription( diff));
#endif
   //
   // TODO: if not zooming possibly scroll up/down
   //
   if( ! [self isZoomEnabled])
   {
      scrollFactor = [self scrollFactor];

      newContentOffset.x = contentOffset.x + diff.x * scrollFactor.x;
      newContentOffset.y = contentOffset.y + diff.y * scrollFactor.y;

      newContentOffset = [self clampedContentOffset:newContentOffset];
      [self setContentOffset:newContentOffset];

 #ifdef SCROLL_DEBUG
      fprintf( stderr, "scrollFactor: %s\n", 
                        CGPointCStringDescription( scrollFactor));

      fprintf( stderr, "contentOffset: %s -> %s\n", 
                        CGPointCStringDescription( contentOffset),
                        CGPointCStringDescription( newContentOffset));
#endif

      return( nil);
   }

   /*
    *  Zoom
    */ 
   zoomFactor = [self zoomFactor];
   if( zoomFactor.x <= 0.0)
      return( nil);

   //
   // use zoom factor relative to current zoom, that makes the zoom
   // smoother
   //
   if( diff.y < 0)
   {
      newZoomFactor.x = zoomFactor.x + (zoomFactor.x * ZOOM_FACTOR);
      newZoomFactor.y = zoomFactor.y + (zoomFactor.y * ZOOM_FACTOR);
   }
   else
   {
      newZoomFactor.x = zoomFactor.x - (zoomFactor.x * ZOOM_FACTOR);
      newZoomFactor.y = zoomFactor.y - (zoomFactor.y * ZOOM_FACTOR);
   }

#ifdef ZOOM_DEBUG
   fprintf( stderr, "zoomFactor: %s -> %s\n", 
                     CGPointCStringDescription( zoomFactor),
                     CGPointCStringDescription( newZoomFactor));
#endif                     
   // make nicey and reproducable, zooming in and out

   newZoomFactor.x = round( newZoomFactor.x * 10) / 10;
   newZoomFactor.y = round( newZoomFactor.y * 10) / 10;
   
   newContentBounds.origin       = contentBounds.origin;
   newContentBounds.size.width   = contentSize.width / newZoomFactor.x;
   newContentBounds.size.height  = contentSize.height / newZoomFactor.y;
 
   newContentBounds = [self clampedContentViewBounds:newContentBounds];

   //
   // look at the position of the mouse cursor, keep contents under it at 
   // the same place zoomed or unzoomed
   // 
   // ...--------------------+ contentView
   // scrollView             |
   // +----------------+     |
   // |   *            |     |  * mouseLocation in contentView points
   // |                |     |    
   // +----------------+     |
   //                        :
   //

   bounds        = [self bounds];
   mouseLocation = [event mouseLocationInView:self];

   factor.x = mouseLocation.x / bounds.size.width;
   factor.y = mouseLocation.y / bounds.size.height;

   // adjust contentOffset so the center remains stable
   newContentOffset    = contentOffset;
   newContentOffset.x -= (newContentBounds.size.width - contentBounds.size.width) * factor.x;
   newContentOffset.y -= (newContentBounds.size.height - contentBounds.size.height) * factor.y;

   newContentOffset = [self clampedContentOffset:newContentOffset];
 
 #ifdef ZOOM_DEBUG
   // fprintf( stderr, "scale: %f\n", scale.y);

   fprintf( stderr, "factor: %s\n", CGPointCStringDescription( factor));

   fprintf( stderr, "zoomFactor: %s -> %s\n", 
                     CGPointCStringDescription( zoomFactor),
                     CGPointCStringDescription( newZoomFactor));

   fprintf( stderr, "position: %s in %s\n", 
                     CGPointCStringDescription( mouseLocation),
                     CGRectCStringDescription( bounds));

   fprintf( stderr, "bounds: %s -> %s\n", 
                     CGRectCStringDescription( contentBounds), 
                     CGRectCStringDescription( newContentBounds));

   fprintf( stderr, "contentOffset: %s -> %s\n", 
                     CGPointCStringDescription( contentOffset),
                     CGPointCStringDescription( newContentOffset));
#endif
   
   [contentView setBounds:newContentBounds];

   [self setContentOffset:newContentOffset];

   return( nil);
}


- (MulleScrollIndicatorView *) scrollIndicatorViewForEvent:(UIEvent *) event
{
   CGPoint                     point;
   MulleScrollIndicatorView    *view;
   CGRect                      bounds;

   point = [event mouseLocationInView:self];
   view  = (MulleScrollIndicatorView *) [self subviewAtPoint:point];

   if( view == _horIndicatorView || view == _verIndicatorView)
      return( view);

   //
   // check  if one of the indicator views is 
   // first responder, then use it as view
   //
   if( [_horIndicatorView isFirstResponder])
      return( _horIndicatorView);
   if( [_verIndicatorView isFirstResponder])
      return( _verIndicatorView);
   return( nil);
}

// left mouse button clicked down (not yet up)
// behaviour os x (TextEdit) : click atop bubble: pageup, click on bubble: niente
// we are also handling mouseDragged events here!
//
- (UIEvent *) mouseDown:(UIEvent *) event
{
   CGPoint                     point;
   CGPoint                     contentOffset;
   CGSize                      contentSize;
   CGPoint                     newContentOffset;
   CGPoint                     distance;
   CGFloat                     bubbleValue;
   MulleScrollIndicatorView    *indicatorView;
   CGRect                      bounds;
   BOOL                        inside;

   // pass thru events, we don't consume, to contained views
   indicatorView = [self scrollIndicatorViewForEvent:event];
   if( ! indicatorView)
      return( event);

   contentSize = [self contentSize];
   if( contentSize.width == 0.0 || contentSize.height == 0.0)
      return( nil);

   point = [event mouseLocationInView:indicatorView];

   // if click is inside the bubble, then don't do anything visible
   // maybe store offset for positioning in a later drag
   if( [indicatorView isInsideBubbleAtPoint:point
                                   offsetAt:&_bubbleDragOffset])
      return( nil);

   // use this to calculate offset into bubble, we want to maintain
   contentOffset = [self contentOffset];
   bounds        = [indicatorView bounds];
   if( indicatorView == _horIndicatorView)
   {
      newContentOffset.x = point.x * (contentSize.width / bounds.size.width); 
      newContentOffset.y = contentOffset.y;
   }
   else
   {
      newContentOffset.y = point.y * (contentSize.height / bounds.size.height); 
      newContentOffset.x = contentOffset.x;
   }

   newContentOffset = [self clampedContentOffset:newContentOffset];

   fprintf( stderr, "x:%s b:%s s:%s o:%s -> n:%s\n", 
                        CGPointCStringDescription( point), 
                        CGRectCStringDescription( bounds),
                        CGSizeCStringDescription( contentSize),
                        CGPointCStringDescription( contentOffset),
                        CGPointCStringDescription( newContentOffset));

   [self setContentOffset:newContentOffset];
   return( nil);
}


- (UIEvent *) mouseDragged:(UIMouseMotionEvent *) event
{
   CGPoint                     point;
   CGPoint                     contentOffset;
   CGSize                      contentSize;
   CGPoint                     newContentOffset;
   CGFloat                     bubbleValue;
   MulleScrollIndicatorView    *indicatorView;
   CGRect                      bounds;
   BOOL                        inside;

   // pass thru events, we don't consume, to contained views
   indicatorView = [self scrollIndicatorViewForEvent:event];
   if( ! indicatorView)
      return( event);

   contentSize = [self contentSize];
   if( contentSize.width == 0.0 || contentSize.height == 0.0)
      return( nil);

   contentOffset = [self contentOffset];
   bounds        = [indicatorView bounds];
   point         = [event mouseLocationInView:indicatorView];

   // are the viewspace pixels in the same domain ?
   point.x      -= _bubbleDragOffset.x;
   point.y      -= _bubbleDragOffset.y;

   if( indicatorView == _horIndicatorView)
   {
      newContentOffset.x = point.x * (contentSize.width / bounds.size.width); 
      newContentOffset.y = contentOffset.y;
   }
   else
   {
      newContentOffset.y = point.y * (contentSize.height / bounds.size.height); 
      newContentOffset.x = contentOffset.x;
   }

   newContentOffset = [self clampedContentOffset:newContentOffset];

   fprintf( stderr, "x:%s b:%s s:%s o:%s -> n:%s\n", 
                        CGPointCStringDescription( point), 
                        CGRectCStringDescription( bounds),
                        CGSizeCStringDescription( contentSize),
                        CGPointCStringDescription( contentOffset),
                        CGPointCStringDescription( newContentOffset));

   [self setContentOffset:newContentOffset];
   return( nil);
}
//
// consume mouseUp events if they hit indicator views
//
- (UIEvent *) mouseUp:(UIEvent *) event
{
   UIView    *view;

   view = [self scrollIndicatorViewForEvent:event];
   if( ! view)
      return( event);

   // consume
   return( nil);
}


- (UIEvent *) rightMouseDown:(UIEvent *) event
{
#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif

   _momentum            = CGPointZero;
   _scrollStartTime     = [event timestamp];
   _locationInWindow       = [event locationInWindow];

   MullePointHistoryStart( &_locationInWindowHistory, _scrollStartTime, _locationInWindow);

   fprintf( stderr, "scrollStartTime: %.2f\n", _scrollStartTime);

   return( nil);
}

//
// we want the pixel we are dragging to stick to the mouse cursor 
// if possible
// 
- (UIEvent *)  rightMouseDragged:(UIMouseMotionEvent *) event 
{
   CGPoint   mouseLocation;
   CGPoint   diff;
   CGPoint   zoomFactor;
   CGRect    bounds;
   CGPoint   contentMousePosition;
   CGPoint   oldContentMousePosition;

   [self setDragging:YES];

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif
   mouseLocation        = [event locationInWindow];
   contentMousePosition = [_contentView convertPoint:mouseLocation 
                                            fromView:nil];
   oldContentMousePosition = [_contentView convertPoint:_locationInWindow 
                                               fromView:nil];

   diff.x = oldContentMousePosition.x - contentMousePosition.x;
   diff.y = oldContentMousePosition.y - contentMousePosition.y;

//  zoomFactor = [self zoomFactor];
//
//   diff.x *= 1.0 / zoomFactor.x;
//   diff.y *= 1.0 / zoomFactor.y;

   [self scrollContentOffsetBy:diff];

#ifdef EVENT_DEBUG
   MullePointHistoryAdd( &_locationInWindowHistory, [event timestamp], mouseLocation);
   fprintf( stderr, "{ timestamp=%.9f, point=%.2f,%2.f (diff=%.2f,%2.f) }\n", 
                  [event timestamp], 
                  mouseLocation.x, mouseLocation.y,
                  diff.x, diff.y);
#endif
   _locationInWindow = mouseLocation;

   return( nil);
}

#define HZ60                  (1.0/60.0)
#define MIN_SCROLLDURATION    0.05
#define SWIPEDURATION         0.05


// TODO: fix momentum when zoomed in, probably by using _locationInWindow
//       and history like in the pan code, translated to the contentView
//       which will implicitly pick up the bounds scaling
//
- (UIEvent *) rightMouseUp:(UIEvent *) event
{
   CAAbsoluteTime                 scrollEndTime;
   CARelativeTime                 scrollDuration;
   CGSize                         scrollAmount;
   CGPoint                        mouseLocation;
   struct MullePointHistoryItem   item;
   CARelativeTime                 diff;

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif

   if( ! [self isDragging])
      return( nil);

   [self setDragging:NO];

   scrollEndTime  = [event timestamp];
#ifdef SCROLLVIEW_DEBUG
   fprintf( stderr, "scrollEndTime: %.2f\n", scrollEndTime);
#endif
   mouseLocation = [event locationInWindow];

   _momentum          = CGPointZero;
   _momentumTimestamp = scrollEndTime;

#ifdef DEBUG
   MullePointHistoryPrint( stderr, &_locationInWindowHistory);
#endif
   item = MullePointHistoryGetItemForTimestamp( &_locationInWindowHistory, scrollEndTime - SWIPEDURATION);

   fprintf( stderr, "%s mouseLocation: %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( mouseLocation));

   MullePointHistoryItemPrintf( stderr, &item);

   if( item.timestamp < scrollEndTime - SWIPEDURATION)
      return( nil);

   //
   // https://medium.com/homullus/recreating-native-ios-scroll-and-momentum-2906d0d711ad
   //
   // On touch end Apple would get momentum by dividing number of pixels that 
   // the user had swiped, and time that the user has swiped for. If the number 
   // of pixels was less than 10 or time was less than 0.5, momentum would be 
   // clamped to zero.
   //
   scrollDuration = CATimeSubtract( scrollEndTime, _scrollStartTime);

   fprintf( stderr, "scrollDuration: %.2f\n", scrollDuration);      
   if( scrollDuration < MIN_SCROLLDURATION)
      return( nil);

   // some value < SWIPEDURATION
   diff  = CATimeSubtract( scrollEndTime, item.timestamp);

   scrollAmount.width  = item.point.x - mouseLocation.x;
   scrollAmount.height = item.point.y - mouseLocation.y;

   fprintf( stderr, "scrollAmount: %.2f,%.2f\n", scrollAmount.width, scrollAmount.height);

   //
   // the general idea is, that you calculate for SWIPEDURATION but actually
   // the sampled time is in "diff". The momentum is scaled for 60Hz updates
   // --- but I don't really know why this works nicely :) trial and error
   //
   if( fabs( scrollAmount.width) >= 10.0)
      _momentum.x = scrollAmount.width * SWIPEDURATION / diff * HZ60;
   if( fabs( scrollAmount.height) >= 10.0)
      _momentum.y = scrollAmount.height * SWIPEDURATION / diff * HZ60;

   fprintf( stderr, "momentum: %.2f,%.2f\n", _momentum.x, _momentum.y);

   return( nil);
}

@end

