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
// #define MOMENTUM_DEBUG

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

   // for right drags it doesn't feel right
   // _clickOrDrag._mouseMotionSuppressionDelay = [[self class] mouseMotionSuppressionDelay];

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

- (CGRect) clampedContentViewBounds:(CGRect) bounds 
{
   CGRect   frame;
   CGRect   oldBounds;
   CGPoint  zoomFactor;
   CGPoint  minZoom;
   CGSize   contentSize;

   oldBounds = [_contentView bounds];
   if( bounds.size.width <= 1.0 || bounds.size.height <= 1.0)
      return( oldBounds);

   frame        = [_contentView frame];
   zoomFactor.x = frame.size.width / bounds.size.width;
   zoomFactor.y = frame.size.height / bounds.size.height;

   contentSize = [self contentSize];

   minZoom.x    = frame.size.width / contentSize.width;
   minZoom.y    = frame.size.height / contentSize.height;

   fprintf( stderr, "zoomFactor: %s\n", CGPointCStringDescription( zoomFactor));
   fprintf( stderr, "minZoom: %s\n", CGPointCStringDescription( minZoom));

   if( zoomFactor.x <= minZoom.x || zoomFactor.y <= minZoom.y)
      return( oldBounds);

   if( zoomFactor.x >= 16.0 || zoomFactor.y >= 16.0)
      return( oldBounds);

   return( bounds);
}

- (CGPoint) clampedContentOffset:(CGPoint) offset 
{
	CGPoint   newOffset;
   CGSize    contentSize;
   CGSize    size;
   CGRect    frame;
   CGRect    bounds;

   contentSize = [self contentSize];
   bounds       = [_contentView bounds];
   size        = CGSizeMake( contentSize.width - bounds.size.width,
                             contentSize.height - bounds.size.height);
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


#define HZ60         (1.0/60.0)
#define DRAGFACTOR   0.95

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

#ifdef MOMENTUM_DEBUG
   if( _momentum.x != 0.0 || _momentum.y != 0.0)
      fprintf( stderr, "momentum: %.2f,%.2f [d:%.4f f:%.4f] @%.4f\n", 
                                    _momentum.x, _momentum.y, 
                                    diff, friction,
                                    CAAbsoluteTimeNow());
#endif                                    
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
   CGRect    bounds;
  
//	CGRect    contentViewFrame;
//	CGRect    contentViewBounds;

   offset            = [self applyMomentumToContentOffset:context];
	size              = [self contentSize];
//	contentViewFrame  = [_contentView frame];
	bounds            = [_contentView bounds]; // or should this be bounds ?
   frame             = [self frame];

	[_horIndicatorView setBubbleOffset:offset.x];
	[_horIndicatorView setBubbleLength:bounds.size.width];
	[_horIndicatorView setContentLength:size.width];

	[_verIndicatorView setBubbleOffset:offset.y];
	[_verIndicatorView setBubbleLength:bounds.size.height];
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
