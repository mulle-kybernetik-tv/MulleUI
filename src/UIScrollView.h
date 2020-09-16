#import "UIView.h"

#import "UIEdgeInsets.h"

#import "CGGeometry+CString.h"


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

#include "MullePointHistory.h"


@interface UIScrollView : UIView
{
	UIView                      *_contentView;
	MulleScrollIndicatorView    *_horIndicatorView;
	MulleScrollIndicatorView    *_verIndicatorView;

// Event handling state
   CGPoint                     _momentum;
   CGPoint                     _locationInWindow;
   CGPoint                     _bubbleDragOffset;
   CAAbsoluteTime              _scrollStartTime;
   CAAbsoluteTime              _momentumTimestamp;
   
   struct MullePointHistory    _locationInWindowHistory;
}

@property UIEdgeInsets                         contentInset;
@property( assign) id <UIScrollViewDelegate>   delegate;
@property( assign) CGSize                      contentSize;
@property( assign, getter=isDragging) BOOL     dragging;
@property( assign, getter=isZoomEnabled) BOOL  zoomEnabled;
@property( assign) BOOL  showsHorizontalScrollIndicator;
@property( assign) BOOL  showsVerticalScrollIndicator;

- (void) setContentOffset:(CGPoint) offset;
- (void) scrollContentOffsetBy:(CGPoint) diff;
- (CGPoint) contentOffset;

// move this into category
- (void) scrollRectToVisible:(CGRect) rect 
                    animated:(BOOL) animated;

// add subviews to contentView not to UIScrollView
- (UIScrollContentView *) contentView;  
- (UIView *) horizontalScrollIndicatorView; 
- (UIView *) verticalScrollIndicatorView;   

- (CGPoint) clampedContentOffset:(CGPoint) offset;
- (CGRect) clampedContentViewBounds:(CGRect) bounds;

+ (UIView *) mulleScrollContentsViewWithFrame:(CGRect) frame;

@end


@interface UIScrollContentView : UIView
@end
