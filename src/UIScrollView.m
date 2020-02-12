#import "UIScrollView.h"

#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "UIView+UIEvent.h"
#import "UIView+UIResponder.h"
#import "UIView+CGGeometry.h"
#import "UIView+Yoga.h"
#import "UIEvent.h"
#import "UIEdgeInsets.h"
#import "MulleScrollIndicatorView.h"


// #define LAYOUT_DEBUG    
// #define EVENT_DEBUG

#define SCROLLER_WIDTH			8
#define SCROLLER_OFFSET_START	8
#define SCROLLER_OFFSET_END	(SCROLLER_WIDTH + SCROLLER_OFFSET_START * 1.5)


@implementation UIScrollView 

- (id) initWithLayer:(CALayer *) layer
{
   assert( ! layer || [layer isKindOfClass:[CALayer class]]);
   CGRect   frame;

   self = [super initWithLayer:layer];
   frame = CGRectZero;

/* 
   the code depends on the layout being called before the render at least
   once
 */ 
   frame.origin = CGPointZero;
   frame.size   = [layer frame].size;

   _contentView = [[UIScrollContentView alloc] initWithFrame:frame];
	[self mulleAddRetainedSubview:_contentView];

   // hide, and show after relayout
   frame = CGRectZero;
   _horIndicatorView = [[MulleScrollIndicatorView alloc] initWithFrame:frame];
//   [_horIndicatorView setUserInteractionEnabled:YES];
	[self mulleAddRetainedSubview:_horIndicatorView];

   _verIndicatorView = [[MulleScrollIndicatorView alloc] initWithFrame:frame];
//   [_verIndicatorView setUserInteractionEnabled:YES];
	[self mulleAddRetainedSubview:_verIndicatorView];

	[self setNeedsLayout];

   return( self);
}


- (void) setContentOffset:(CGPoint) offset
{
	CGRect   bounds;

	bounds = [_contentView bounds];
#ifdef LAYOUT_DEBUG
	fprintf( stderr, "bounds %s -> ", CGRectCStringDescription( bounds));
#endif   
	bounds.origin.x = -offset.x;
	bounds.origin.y = -offset.y;
#ifdef LAYOUT_DEBUG
	fprintf( stderr, "%s\n", CGRectCStringDescription( bounds));
#endif   
	[_contentView setBounds:bounds];
}


- (CGPoint) contentOffset
{
	CGRect   bounds;

   assert( _contentView);
	bounds = [_contentView bounds];
	return( CGPointMake( -bounds.origin.x, -bounds.origin.y));
}


- (UIScrollContentView *) contentView  // subview index #0
{
	return( _contentView);
}


- (UIView *) horizontalScrollIndicatorView  // subview index #n - 2
{
	return( _horIndicatorView);
}


- (UIView *) verticalScrollIndicatorView    // subview index #n - 1
{
	return( _verIndicatorView);
}

- (CGPoint) clampedContentOffset:(CGPoint) offset 
{
	CGPoint   newOffset;
   CGSize    contentSize;
   CGSize    size;
   CGRect    frame;

   contentSize = [self contentSize];
   frame       = [self frame];
   size        = CGSizeMake( contentSize.width - frame.size.width,
                             contentSize.height - frame.size.height);
   newOffset = MulleCGPointClampToSize( offset, size);
   return( newOffset);
}


- (void) scrollContentOffsetBy:(CGPoint) diff 
{
	CGPoint   offset;
	CGPoint   newOffset;
      
   offset      = [self contentOffset];
	newOffset.x = offset.x + diff.x;
	newOffset.y = offset.y + diff.y;
	offset      = [self clampedContentOffset:newOffset];
   [self setContentOffset:offset];
}


//
// event handling
// In category ?
//
- (UIEvent *) scrollWheel:(UIMouseScrollEvent *) event
{
	CGPoint   offset;
	CGPoint   newOffset;
	CGPoint   diff;

	diff = [event scrollOffset];

	fprintf( stderr, "scrollWheell: %s\n", CGPointCStringDescription( diff));

   [self scrollContentOffsetBy:diff];

	return( nil);
}


// left mouse button clicked down (not yet up)
// behaviour os x (TextEdit) : click atop bubble: pageup, click on bubble: niente
//
- (UIEvent *) mouseDown:(UIEvent *) event
{
   CGPoint                     point;
   CGPoint                     contentOffset;
   CGSize                      contentSize;
   CGFloat                     bubbleValue;
   MulleScrollIndicatorView    *view;
   CGRect                      bounds;

	point = [event mousePositionInView:self];
	view  = (MulleScrollIndicatorView *) [self subviewAtPoint:point];

	if( view != _horIndicatorView && view != _verIndicatorView)
      return( event);

   contentSize = [self contentSize];
   if( contentSize.width == 0.0 || contentSize.height == 0.0)
      return( nil);

   contentOffset = [self contentOffset];
   bounds        = [view bounds];
	point         = [event mousePositionInView:view];
   bubbleValue   = [view bubbleValueAtPoint:point];

	if( view == _horIndicatorView)
	{
      contentOffset.x = bubbleValue * (contentSize.width / bounds.size.width); 
      fprintf( stderr, "hor: b:%.2f x:%s o:%s\n", 
                           bubbleValue,
                           CGPointCStringDescription( point), 
                           CGPointCStringDescription( contentOffset));
	}
   else
	{
      contentOffset.y = bubbleValue * (contentSize.height / bounds.size.height); 
      fprintf( stderr, "ver: b:%.2f x:%s o:%s\n", 
                           bubbleValue,
                           CGPointCStringDescription( point), 
                           CGPointCStringDescription( contentOffset));
	}

   [self setContentOffset:contentOffset];
	return( nil);
}

- (UIEvent *) mouseDragged:(UIMouseMotionEvent *) event
{
   return( [self mouseDown:event]);
}

//
// consume mouseUp events if they hit indicator views
//
- (UIEvent *) mouseUp:(UIEvent *) event
{
   CGPoint   point;
   UIView    *view;

	point = [event mousePositionInView:self];
	view  = [self subviewAtPoint:point];

	point = [event mousePositionInView:self];
	view  = [self subviewAtPoint:point];

	if( view != _horIndicatorView && view != _verIndicatorView)
      return( event);

	if( view == _horIndicatorView)
      fprintf( stderr, "hor: up\n");      
   else
      fprintf( stderr, "ver: up\n");      

	return( nil);
}


- (UIEvent *) rightMouseDown:(UIEvent *) event
{
#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif
   [self setDragging:YES];

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

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif
   mousePosition = [event mousePosition];

   diff.x        = _mousePosition.x - mousePosition.x;
   diff.y        = _mousePosition.y - mousePosition.y;
   [self scrollContentOffsetBy:diff];

   MullePointHistoryAdd( &_mousePositionHistory, [event timestamp], mousePosition);

   _mousePosition = mousePosition;

   return( nil);
}

#define HZ60                  (1.0/60.0)
#define DRAGFACTOR            0.95
#define MIN_SCROLLDURATION    0.05
#define SWIPEDURATION         0.2


- (UIEvent *) rightMouseUp:(UIEvent *) event
{
   CAAbsoluteTime                 scrollEndTime;
   CARelativeTime                 scrollDuration;
   CGSize                         scrollAmount;
   CGPoint                        mousePosition;
   struct MullePointHistoryItem   item;

#ifdef EVENT_DEBUG
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);
#endif

   scrollEndTime  = [event timestamp];
   fprintf( stderr, "scrollEndTime: %.2f\n", scrollEndTime);

   scrollDuration = CATimeSubtract( scrollEndTime, _scrollStartTime);

   fprintf( stderr, "scrollDuration: %.2f\n", scrollDuration);

   mousePosition = [event mousePosition];

   _momentum          = CGPointZero;
   _momentumTimestamp = scrollEndTime;

   item = MullePointHistoryGetItemForTimestamp( &_mousePositionHistory, scrollEndTime - SWIPEDURATION);

   MullePointHistoryItemPrintf( stderr, &item);

   if( item.timestamp >= scrollEndTime - SWIPEDURATION)
   {
      scrollAmount.width  = item.point.x - mousePosition.x;
      scrollAmount.height = item.point.y - mousePosition.y;

      fprintf( stderr, "scrollAmount: %.2f,%.2f\n", scrollAmount.width, scrollAmount.height);

      //
      // https://medium.com/homullus/recreating-native-ios-scroll-and-momentum-2906d0d711ad
      //
      // On touch end Apple would get momentum by dividing number of pixels that 
      // the user had swiped, and time that the user has swiped for. If the number 
      // of pixels was less than 10 or time was less than 0.5, momentum would be 
      // clamped to zero.
      //
      if( scrollDuration >= MIN_SCROLLDURATION)
      {
         if( fabs( scrollAmount.width) >= 10.0)
            _momentum.x = scrollAmount.width / scrollDuration * HZ60;
         if( fabs( scrollAmount.height) >= 10.0)
            _momentum.y = scrollAmount.height / scrollDuration * HZ60;

         fprintf( stderr, "momentum: %.2f,%.2f\n", _momentum.x, _momentum.y);
      }
   }

   [self setDragging:NO];

   // do something here ?
   
	return( nil);
}


- (CGPoint) applyMomentumToContentOffset:(CGContext *) context
{
	CGPoint          offset;
	CGPoint          newOffset;
   CAAbsoluteTime   previous;
   CARelativeTime   diff;
   CGFloat          friction;
   CAAbsoluteTime   now;

   now      = [context renderStartTimestamp];
   previous = _momentumTimestamp;

   diff     = CATimeSubtract( now, previous);

   // 1/60 = 0.166  so if our last render was 0.0s before, we use 1.0
   //                  if the last render was 0.166s before,we use 0.95
   //                  interpolate other numbers

   // diff is 0        : friction is 1
   // diff is 0.5/60.0 : friction is (1-0.95) * diff + 0.95
   // diff is 1.0/60.0 : friction is 0.95
   // diff is 2.0/60.0 : friction is (1-0.95) * diff + 0.95 

   diff     = diff / HZ60; 
   friction = 1 - (1 - DRAGFACTOR) * diff;

   _momentum.x *= friction;  
   _momentum.y *= friction;
   if( fabs( _momentum.x) < 0.01)
      _momentum.x = 0.0;
   if( fabs( _momentum.y) < 0.01)
      _momentum.y = 0.0;

   if( _momentum.x != 0.0 || _momentum.y != 0.0)
      fprintf( stderr, "momentum: %.2f,%.2f [d:%.4f f:%.4f] @%.4f\n", 
                                    _momentum.x, _momentum.y, 
                                    diff, friction,
                                    CAAbsoluteTimeNow());
   _momentumTimestamp = now;

	offset      = [self contentOffset];

   newOffset.x = offset.x + _momentum.x; 
   newOffset.y = offset.y + _momentum.y;

   if( ! CGPointEqualToPoint( offset, newOffset))
   {
	   offset = [self clampedContentOffset:newOffset];
	   [self setContentOffset:offset];
   }
   return( offset);
}


- (void) renderWithContext:(CGContext *) context
{
	CGPoint   offset;
	CGSize    size;
   CGRect    frame;
  
//	CGRect    contentViewFrame;
//	CGRect    contentViewBounds;

   offset            = [self applyMomentumToContentOffset:context];
	size              = [self contentSize];
//	contentViewFrame  = [_contentView frame];
	frame             = [self frame];

	[_horIndicatorView setBubbleOffset:offset.x];
	[_horIndicatorView setBubbleLength:frame.size.width];
	[_horIndicatorView setContentLength:size.width];

	[_verIndicatorView setBubbleOffset:offset.y];
	[_verIndicatorView setBubbleLength:frame.size.height];
	[_verIndicatorView setContentLength:size.height];

	[super renderWithContext:context];
}


- (void) layoutSubviews
{
	CGRect         bounds;
	CGRect         horFrame;
	CGRect         verFrame;
	CGFloat        offset;
	UIEdgeInsets   insets;

	[super layoutSubviews];

	bounds = [self bounds];

#ifdef LAYOUT_DEBUG
   fprintf( stderr, "%s %s bounds: %s\n",
   					__PRETTY_FUNCTION__, 
                  [self cStringDescription],
                  CGRectCStringDescription( bounds));
#endif

// determined solely by contentSize/offset and own bounds
	[_contentView setFrame:bounds];

	// currently these scrollers are 8 pixel wide and 4 pixels offset
	// the 6.0 is so that scrollers don't overlap if both are visible
	insets   = UIEdgeInsetsMake( 0.0, SCROLLER_OFFSET_START, SCROLLER_OFFSET_START, SCROLLER_OFFSET_END);
	horFrame = UIEdgeInsetsInsetRect( bounds, insets);

	horFrame.origin.y     = horFrame.size.height + horFrame.origin.y - SCROLLER_WIDTH;
	horFrame.size.height  = SCROLLER_WIDTH ;
;

#ifdef LAYOUT_DEBUG
   fprintf( stderr, "%s %s bounds: %s\n",
   					__PRETTY_FUNCTION__, 
                  [_horIndicatorView cStringDescription],
                  CGRectCStringDescription( horFrame));
#endif
	[_horIndicatorView setFrame:horFrame];

	insets   = UIEdgeInsetsMake( SCROLLER_OFFSET_START, 0.0, SCROLLER_OFFSET_END, SCROLLER_OFFSET_START);
	verFrame = UIEdgeInsetsInsetRect( bounds, insets);

	verFrame.origin.x   = verFrame.size.width + verFrame.origin.x - SCROLLER_WIDTH;
	verFrame.size.width = SCROLLER_WIDTH;

#ifdef LAYOUT_DEBUG
   fprintf( stderr, "%s %s bounds: %s\n",
   					__PRETTY_FUNCTION__, 
                  [_verIndicatorView cStringDescription],
                  CGRectCStringDescription( verFrame));
#endif
	[_verIndicatorView setFrame:verFrame];
}


- (void) scrollRectToVisible:(CGRect) rect 
                    animated:(BOOL) animated
{
}

@end


@implementation UIScrollContentView : UIView
@end
