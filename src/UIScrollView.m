#import "UIScrollView.h"

#import "CGGeometry+CString.h"
#import "UIEvent.h"


@implementation UIScrollView 

- (id) initWithLayer:(CALayer *) layer
{
	self = [super initWithLayer:layer];

//	[self setClipsSubviews:NO];

	return( self);
}


- (void) setContentOffset:(CGPoint) offset
{
	CGRect   bounds;

	bounds = [self bounds];
	fprintf( stderr, "bounds %s -> ", CGRectCStringDescription( bounds));
	bounds.origin = offset;
	fprintf( stderr, "%s\n", CGRectCStringDescription( bounds));
	[self setBounds:bounds];
}


- (CGPoint) contentOffset
{
	CGRect   bounds;

	bounds = [self bounds];
	return( bounds.origin);
}


- (void) setContentSize:(CGSize) size
{
	CGRect   bounds;

	bounds = [self bounds];
	bounds.size = size;
	[self setBounds:bounds];
}


- (CGSize) contentSize
{
	CGRect   bounds;

	bounds = [self bounds];
	return( bounds.size);
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

@end
