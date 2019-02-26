#import "UIView.h"


/* 
 * a UIScrollView is a container for UIViews like a regular UIView
 * a specialty of the UIScrollView is, that it doesn't scale the
 * subviews.
 */
@class UIScrollContentView;
@class MulleScrollIndicatorView;

@interface UIScrollView : UIView
{
	UIScrollContentView       *_contentView;
	MulleScrollIndicatorView  *_horIndicatorView;
	MulleScrollIndicatorView  *_verIndicatorView;
}

- (void) setContentOffset:(CGPoint) offset;
- (CGPoint) contentOffset;
- (void) contentSize:(CGSize) offset;
- (CGSize) contentSize;

// add subviews to contentView not to UIScrollView
- (UIScrollContentView *) contentView;  
- (UIView *) horizontalScrollIndicatorView; 
- (UIView *) verticalScrollIndicatorView;   

@end


@interface UIScrollContentView : UIView
{
}
@end
