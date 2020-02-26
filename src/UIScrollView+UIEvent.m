#import "UIScrollView+UIEvent.h"

#import "CGGeometry+CString.h"
#import "UIView+UIEvent.h"
#import "UIView+UIResponder.h"
#import "UIEvent.h"
#import "MulleScrollIndicatorView.h"


// #define LAYOUT_DEBUG    
// #define EVENT_DEBUG

@implementation UIScrollView( UIEvent)


//
// event handling
// In category ?
//
- (UIEvent *) scrollWheel:(UIMouseScrollEvent *) event
{
	CGPoint   offset;
	CGPoint   newOffset;
	CGPoint   diff;

	diff     = [event acceleratedScrollOffset];
	fprintf( stderr, "scrollWheel: %s\n", CGPointCStringDescription( diff));

   [self scrollContentOffsetBy:diff];

	return( nil);
}


- (MulleScrollIndicatorView *) scrollIndicatorViewForEvent:(UIEvent *) event
{
   CGPoint                     point;
   MulleScrollIndicatorView    *view;
   CGRect                      bounds;

	point = [event mousePositionInView:self];
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

	point = [event mousePositionInView:indicatorView];

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
	point         = [event mousePositionInView:indicatorView];

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
   _mousePosition       = [event mousePosition];

   MullePointHistoryStart( &_mousePositionHistory, _scrollStartTime, _mousePosition);

   fprintf( stderr, "scrollStartTime: %.2f\n", _scrollStartTime);

	return( nil);
}


- (UIEvent *)  rightMouseDragged:(UIMouseMotionEvent *) event 
{
   CGPoint   mousePosition;
   CGPoint   diff;

   [self setDragging:YES];

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif
   mousePosition = [event mousePosition];

   diff.x        = _mousePosition.x - mousePosition.x;
   diff.y        = _mousePosition.y - mousePosition.y;
   [self scrollContentOffsetBy:diff];

   MullePointHistoryAdd( &_mousePositionHistory, [event timestamp], mousePosition);
   fprintf( stderr, "{ timestamp=%.9f, point=%.2f,%2.f }\n", 
                  [event timestamp], mousePosition.x, mousePosition.y);
   _mousePosition = mousePosition;

   return( nil);
}

#define HZ60                  (1.0/60.0)
#define MIN_SCROLLDURATION    0.05
#define SWIPEDURATION         0.05


- (UIEvent *) rightMouseUp:(UIEvent *) event
{
   CAAbsoluteTime                 scrollEndTime;
   CARelativeTime                 scrollDuration;
   CGSize                         scrollAmount;
   CGPoint                        mousePosition;
   struct MullePointHistoryItem   item;
   CARelativeTime                 diff;

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif

   if( ! [self isDragging])
      return( nil);

   [self setDragging:NO];

   scrollEndTime  = [event timestamp];
   fprintf( stderr, "scrollEndTime: %.2f\n", scrollEndTime);

   mousePosition = [event mousePosition];

   _momentum          = CGPointZero;
   _momentumTimestamp = scrollEndTime;

#ifdef DEBUG
   MullePointHistoryPrint( stderr, &_mousePositionHistory);
#endif
   item = MullePointHistoryGetItemForTimestamp( &_mousePositionHistory, scrollEndTime - SWIPEDURATION);

   fprintf( stderr, "mousePosition: %s\n", CGPointCStringDescription( mousePosition));

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

   scrollAmount.width  = item.point.x - mousePosition.x;
   scrollAmount.height = item.point.y - mousePosition.y;

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

