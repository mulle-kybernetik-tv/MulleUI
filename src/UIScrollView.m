#import "UIScrollView.h"

#import "CGGeometry+CString.h"
#import "UIView+UIEvent.h"
#import "UIEvent.h"
#import "UIEdgeInsets.h"
#import "MulleScrollIndicatorView.h"


#define LAYOUT_DEBUG    
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

   _contentView = [[UIScrollContentView alloc] initWithFrame:frame];
	[self addSubview:_contentView];
	[_contentView release];

   _horIndicatorView = [[MulleScrollIndicatorView alloc] initWithFrame:frame];
	[self addSubview:_horIndicatorView];
	[_horIndicatorView release];

   _verIndicatorView = [[MulleScrollIndicatorView alloc] initWithFrame:frame];
	[self addSubview:_verIndicatorView];
	[_verIndicatorView release];

	[self setNeedsLayout];

   return( self);
}


- (void) setContentOffset:(CGPoint) offset
{
	CGRect   bounds;

	bounds = [_contentView bounds];
	fprintf( stderr, "bounds %s -> ", CGRectCStringDescription( bounds));
	bounds.origin = offset;
	fprintf( stderr, "%s\n", CGRectCStringDescription( bounds));
	[_contentView setBounds:bounds];
}


- (CGPoint) contentOffset
{
	CGRect   bounds;

	bounds = [_contentView bounds];
	return( bounds.origin);
}


- (void) setContentSize:(CGSize) size
{
	CGRect   bounds;

	bounds = [_contentView bounds];
	bounds.size = size;
	[_contentView setBounds:bounds];
}


- (CGSize) contentSize
{
	CGRect   bounds;

	bounds = [self bounds];
	return( bounds.size);
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


//
// event handling
// In category ?
//
- (UIEvent *) scrollWheel:(UIMouseScrollEvent *) event
{
	CGPoint   offset;
	CGPoint   scrollOffset;

	scrollOffset = [event scrollOffset];
	fprintf( stderr, "scroll: %s\n", CGPointCStringDescription( scrollOffset));

	offset    = [self contentOffset];
	offset.x += scrollOffset.x;
	offset.y += scrollOffset.y;
	[self setContentOffset:offset];

	return( nil);
}



// left mouse button clicked down (not yet up)
// behaviour os x (TextEdit) : click atop bubble: pageup, click on bubble: niente
//
- (UIEvent *) mouseDown:(UIEvent *) event
{
   CGPoint   point;
	CGPoint   translated;
   CGPoint   offset;
   UIView    *view;

	point = [event point];
	view  = [self subviewAtPoint:point];

	if( view == _horIndicatorView)
	{
      translated = [self translatedPoint:point];
      offset     = [view contentOffsetAtPoint:translated];
      [self setContentOffset:offset];
		return( nil);
	}

	if( view == _verIndicatorView)
	{
      translated = [self translatedPoint:point];
      offset     = [view contentOffsetAtPoint:translated];
      [self setContentOffset:offset];
		return( nil);
	}

	return( event);
}



- (void) renderWithContext:(CGContext *) context
{
	CGPoint   offset;
	CGSize    size;
	CGRect    contentViewFrame;
	CGRect    contentViewBounds;

	offset = [self contentOffset];
	size   = [self contentSize];

	contentViewFrame  = [_contentView frame];
	contentViewBounds = [_contentView bounds];

	[_horIndicatorView setBubbleOffset:offset.x];
	[_horIndicatorView setBubbleLength:contentViewFrame.size.width];
	[_horIndicatorView setContentLength:contentViewBounds.size.width];

	[_verIndicatorView setBubbleOffset:offset.y];
	[_verIndicatorView setBubbleLength:contentViewFrame.size.height];
	[_verIndicatorView setContentLength:contentViewBounds.size.height];

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

@end


@implementation UIScrollContentView : UIView
@end
