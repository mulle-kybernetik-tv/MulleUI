#import "UIView.h"

#import "UIEdgeInsets.h"


/* 
 * a UIScrollView is a container for UIViews like a regular UIView
 * a specialty of the UIScrollView is, that it doesn't scale the
 * subviews.
 */
@class UIScrollContentView;
@class MulleScrollIndicatorView;
@class UIScrollView;

@protocol UIScrollViewDelegate

@optional
- (void) scrollViewDidScroll:(UIScrollView *) scrollView;
- (void) scrollViewDidZoom:(UIScrollView *) scrollView;
- (void) scrollViewWillBeginDragging:(UIScrollView *) scrollView;
- (void) scrollViewWillEndDragging:(UIScrollView *) scrollView 
                      withVelocity:(CGPoint) velocity 
               targetContentOffset:(CGPoint *) targetContentOffset;
- (void) scrollViewDidEndDragging:(UIScrollView *) scrollView 
                   willDecelerate:(BOOL)decelerate;
- (void) scrollViewWillBeginDecelerating:(UIScrollView *) scrollView;
- (void) scrollViewDidEndDecelerating:(UIScrollView *) scrollView;
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *) scrollView;
- (UIView *) viewForZoomingInScrollView:(UIScrollView *) scrollView;
- (void) scrollViewWillBeginZooming:(UIScrollView *) scrollView 
                           withView:(UIView *) view;
- (void) scrollViewDidEndZooming:(UIScrollView *) scrollView 
                        withView:(UIView *) view 
                         atScale:(CGFloat) scale;
- (BOOL) scrollViewShouldScrollToTop:(UIScrollView *) scrollView;
- (void) scrollViewDidScrollToTop:(UIScrollView *) scrollView;

@end


@interface UIScrollView : UIView
{
	UIScrollContentView       *_contentView;
	MulleScrollIndicatorView  *_horIndicatorView;
	MulleScrollIndicatorView  *_verIndicatorView;
}

@property UIEdgeInsets   contentInset;
@property( assign) id <UIScrollViewDelegate>  delegate;

- (BOOL) isDragging;

- (void) setContentOffset:(CGPoint) offset;
- (CGPoint) contentOffset;
- (void) setContentSize:(CGSize) offset;
- (CGSize) contentSize;

// move this into category
- (void) scrollRectToVisible:(CGRect) rect 
                    animated:(BOOL) animated;

// add subviews to contentView not to UIScrollView
- (UIScrollContentView *) contentView;  
- (UIView *) horizontalScrollIndicatorView; 
- (UIView *) verticalScrollIndicatorView;   

@end


@interface UIScrollContentView : UIView
{
}
@end
