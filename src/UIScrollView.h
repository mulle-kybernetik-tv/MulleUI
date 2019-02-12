#import "UIView.h"


/* a UIScrollView is a container for UIViews like a regular UIView
 * a specialty of the UIScrollView is, that it doesn't scale the
 * subviews.
 */
@interface UIScrollView : UIView

- (void) setContentOffset:(CGPoint) offset;
- (CGPoint) contentOffset;
- (void) contentSize:(CGSize) offset;
- (CGSize) contentSize;

@end

